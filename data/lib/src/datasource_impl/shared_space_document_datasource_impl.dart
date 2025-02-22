// LinShare is an open source filesharing software, part of the LinPKI software
// suite, developed by Linagora.
//
// Copyright (C) 2020 LINAGORA
//
// This program is free software: you can redistribute it and/or modify it under the
// terms of the GNU Affero General Public License as published by the Free Software
// Foundation, either version 3 of the License, or (at your option) any later version,
// provided you comply with the Additional Terms applicable for LinShare software by
// Linagora pursuant to Section 7 of the GNU Affero General Public License,
// subsections (b), (c), and (e), pursuant to which you must notably (i) retain the
// display in the interface of the “LinShare™” trademark/logo, the "Libre & Free" mention,
// the words “You are using the Free and Open Source version of LinShare™, powered by
// Linagora © 2009–2020. Contribute to Linshare R&D by subscribing to an Enterprise
// offer!”. You must also retain the latter notice in all asynchronous messages such as
// e-mails sent with the Program, (ii) retain all hypertext links between LinShare and
// http://www.linshare.org, between linagora.com and Linagora, and (iii) refrain from
// infringing Linagora intellectual property rights over its trademarks and commercial
// brands. Other Additional Terms apply, see
// <http://www.linshare.org/licenses/LinShare-License_AfferoGPL-v3.pdf>
// for more details.
// This program is distributed in the hope that it will be useful, but WITHOUT ANY
// WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for
// more details.
// You should have received a copy of the GNU Affero General Public License and its
// applicable Additional Terms for LinShare along with this program. If not, see
// <http://www.gnu.org/licenses/> for the GNU Affero General Public License version
//  3 and <http://www.linshare.org/licenses/LinShare-License_AfferoGPL-v3.pdf> for
//  the Additional Terms applicable to LinShare software.
//

import 'dart:async';
import 'dart:io';

import 'package:data/data.dart';
import 'package:data/src/datasource/shared_space_document_datasource.dart';
import 'package:data/src/network/config/endpoint.dart';
import 'package:data/src/network/model/request/copy_body_request.dart';
import 'package:data/src/network/model/request/create_shared_space_node_folder_request.dart';
import 'package:data/src/network/model/sharedspacedocument/work_group_document_dto.dart';
import 'package:data/src/network/model/sharedspacedocument/work_group_folder_dto.dart';
import 'package:data/src/util/constant.dart';
import 'package:dio/dio.dart';
import 'package:domain/domain.dart';
import 'package:domain/src/model/sharedspace/shared_space_id.dart';
import 'package:domain/src/model/sharedspacedocument/work_group_node_id.dart';
import 'package:ext_storage/ext_storage.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';

class SharedSpaceDocumentDataSourceImpl implements SharedSpaceDocumentDataSource {
  final LinShareHttpClient _linShareHttpClient;
  final RemoteExceptionThrower _remoteExceptionThrower;
  final LinShareDownloadManager _linShareDownloadManager;

  SharedSpaceDocumentDataSourceImpl(
    this._linShareHttpClient,
    this._remoteExceptionThrower,
    this._linShareDownloadManager
  );

  @override
  Future<List<WorkGroupNode?>> getAllChildNodes(
      SharedSpaceId sharedSpaceId,
      {WorkGroupNodeId? parentNodeId}
  ) {
    return Future.sync(() async {
      return (await _linShareHttpClient.getWorkGroupChildNodes(sharedSpaceId, parentId: parentNodeId))
          .map<WorkGroupNode?>((workgroupNode) {
            if (workgroupNode is WorkGroupDocumentDto) return workgroupNode.toWorkGroupDocument();

            if (workgroupNode is WorkGroupNodeFolderDto) return workgroupNode.toWorkGroupFolder();

            return null;
          })
          .where((node) => node != null)
          .toList();
    }).catchError((error) {
      _remoteExceptionThrower.throwRemoteException(error, handler: (DioError error) {
        if (error.response?.statusCode == 404) {
          throw GetChildNodesNotFoundException();
        } else if (error.response?.statusCode == 403) {
          throw NotAuthorized();
        } else {
          throw UnknownError(error.response?.statusMessage!);
        }
      });
    });
  }

  @override
  Future<List<WorkGroupNode>> copyToSharedSpace(CopyRequest copyRequest, SharedSpaceId destinationSharedSpaceId, {WorkGroupNodeId? destinationParentNodeId}) {
    return Future.sync(() async {
      return (await _linShareHttpClient.copyWorkGroupNodeToSharedSpaceDestination(
            copyRequest.toCopyBodyRequest(),
            destinationSharedSpaceId,
            destinationParentNodeId: destinationParentNodeId))
          .map((workgroupNode) {
            if (workgroupNode is WorkGroupDocumentDto) {
              return workgroupNode.toWorkGroupDocument();
            }
            if (workgroupNode is WorkGroupNodeFolderDto) {
              return workgroupNode.toWorkGroupFolder();
            }
            return null;})
          .where((node) => node != null)
          .map((node) => node!)
          .toList();
    }).catchError((error) {
      _remoteExceptionThrower.throwRemoteException(error, handler: (DioError error) {
        if (error.response?.statusCode == 404) {
          throw WorkGroupNodeNotFoundException();
        } else if (error.response?.statusCode == 403) {
          throw NotAuthorized();
        } else {
          throw UnknownError(error.response?.statusMessage!);
        }
      });
    });
  }

  @override
  Future<WorkGroupNode> removeSharedSpaceNode(SharedSpaceId sharedSpaceId, WorkGroupNodeId sharedSpaceNodeId) {
    return Future.sync(() async {
      final workGroupNode = await _linShareHttpClient.removeSharedSpaceNode(sharedSpaceId, sharedSpaceNodeId);

      if (workGroupNode is WorkGroupDocumentDto) return workGroupNode.toWorkGroupDocument();
      if (workGroupNode is WorkGroupNodeFolderDto) return workGroupNode.toWorkGroupFolder();

      return workGroupNode as WorkGroupNode;
    }).catchError((error) {
      _remoteExceptionThrower.throwRemoteException(error, handler: (DioError error) {
        if (error.response?.statusCode == 404) {
          throw WorkGroupNodeNotFoundException();
        } else if (error.response?.statusCode == 403) {
          throw NotAuthorized();
        } else {
          throw UnknownError(error.response?.statusMessage!);
        }
      });
    });
  }

  @override
  Future<List<DownloadTaskId>> downloadNodes(List<WorkGroupNode> workgroupNodes, Token token, Uri baseUrl) async {
    var externalStorageDirPath;
    if (Platform.isAndroid) {
        externalStorageDirPath = await ExtStorage.getExternalStoragePublicDirectory(ExtStorage.DIRECTORY_DOWNLOADS);
    } else if (Platform.isIOS) {
        externalStorageDirPath = (await getApplicationDocumentsDirectory()).absolute.path;
    } else {
        throw DeviceNotSupportedException();
    }

    final taskIds = await Future.wait(
        workgroupNodes.map((node) async => await FlutterDownloader.enqueue(
            url: Endpoint.sharedSpaces
                .withPathParameter(node.sharedSpaceId.uuid)
                .withPathParameter('nodes')
                .downloadServicePath(node.workGroupNodeId.uuid)
                .generateDownloadUrl(baseUrl),
            savedDir: externalStorageDirPath,
            headers: {Constant.authorization: 'Bearer ${token.token}'},
            showNotification: true,
            openFileFromNotification: true)));

      return taskIds
          .where((id) => id != null)
          .map((taskId) => DownloadTaskId(taskId!))
          .toList();
  }

  @override
  Future<String> downloadNodeIOS(
      WorkGroupNode workgroupNode, Token token, Uri baseUrl, CancelToken cancelToken) async {
    return _linShareDownloadManager.downloadFile(
        Endpoint.sharedSpaces
            .withPathParameter(workgroupNode.sharedSpaceId.uuid)
            .withPathParameter('nodes')
            .downloadServicePath(workgroupNode.workGroupNodeId.uuid)
            .generateDownloadUrl(baseUrl),
        getTemporaryDirectory(),
        workgroupNode.name,
        token,
        cancelToken: cancelToken);
  }

  @override
  Future<WorkGroupFolder> createSharedSpaceFolder(
    SharedSpaceId sharedSpaceId,
    CreateSharedSpaceNodeFolderRequest createSharedSpaceNodeRequest) {
    return Future.sync(() async {
      final workGroupNode = await _linShareHttpClient.createSharedSpaceNodeFolder(sharedSpaceId, createSharedSpaceNodeRequest);
      return workGroupNode.toWorkGroupFolder();
    }).catchError((error) {
      _remoteExceptionThrower.throwRemoteException(error, handler: (DioError error) {
        if (error.response?.statusCode == 404) {
          throw SharedSpaceNotFound();
        } else if (error.response?.statusCode == 403) {
          throw NotAuthorized();
        } else {
          throw UnknownError(error.response?.statusMessage!);
        }
      });
    });
  }

  @override
  Future<String> downloadPreviewWorkGroupDocument(WorkGroupDocument workGroupDocument,
      DownloadPreviewType downloadPreviewType, Token token, Uri baseUrl, CancelToken cancelToken) {
    var downloadUrl;
    if (downloadPreviewType == DownloadPreviewType.original) {
      downloadUrl = Endpoint.sharedSpaces
          .withPathParameter(workGroupDocument.sharedSpaceId.uuid)
          .withPathParameter('nodes')
          .downloadServicePath(workGroupDocument.workGroupNodeId.uuid)
          .generateDownloadUrl(baseUrl);
    } else {
      downloadUrl = Endpoint.sharedSpaces
          .withPathParameter(workGroupDocument.sharedSpaceId.uuid)
          .withPathParameter('nodes')
          .withPathParameter(workGroupDocument.workGroupNodeId.uuid)
          .withPathParameter(Endpoint.thumbnail)
          .withPathParameter(
              downloadPreviewType == DownloadPreviewType.image ? 'medium?base64=false' : 'pdf')
          .generateEndpointPath();
    }
    return _linShareDownloadManager.downloadFile(
        downloadUrl,
        getTemporaryDirectory(),
        workGroupDocument.name +
            '${downloadPreviewType == DownloadPreviewType.thumbnail ? '.pdf' : ''}',
        token,
        cancelToken: cancelToken);
  }

  @override
  Future<WorkGroupNode> renameSharedSpaceNode(SharedSpaceId sharedSpaceId, WorkGroupNodeId sharedSpaceNodeId, RenameWorkGroupNodeRequest renameRequest) {
    return Future.sync(() async {
      final workGroupNode = await _linShareHttpClient.renameSharedSpaceNode(sharedSpaceId, sharedSpaceNodeId, renameRequest.toRenameWorkGroupNodeBodyRequest());

      if (workGroupNode is WorkGroupDocumentDto) return workGroupNode.toWorkGroupDocument();
      if (workGroupNode is WorkGroupNodeFolderDto) return workGroupNode.toWorkGroupFolder();

      return workGroupNode as WorkGroupNode;
    }).catchError((error) {
      _remoteExceptionThrower.throwRemoteException(error, handler: (DioError error) {
        if (error.response?.statusCode == 404) {
          throw WorkGroupNodeNotFoundException();
        } else if (error.response?.statusCode == 403) {
          throw NotAuthorized();
        } else {
          throw UnknownError(error.response?.statusMessage!);
        }
      });
    });
  }

  @override
  Future<WorkGroupNode?> getWorkGroupNode(SharedSpaceId sharedSpaceId, WorkGroupNodeId workGroupNodeId, {bool hasTreePath = false}) {
    return Future.sync(() async {
      final workGroupNode = (await _linShareHttpClient.getWorkGroupNode(sharedSpaceId, workGroupNodeId, hasTreePath: hasTreePath));

      if (workGroupNode is WorkGroupDocumentDto) {
        return workGroupNode.toWorkGroupDocument();
      }

      if (workGroupNode is WorkGroupNodeFolderDto) {
        return workGroupNode.toWorkGroupFolder();
      }

      return workGroupNode as WorkGroupNode;
    }).catchError((error) {
      _remoteExceptionThrower.throwRemoteException(error, handler: (DioError error) {
        if (error.response?.statusCode == 404) {
          throw WorkGroupNodeNotFoundException();
        } else if (error.response?.statusCode == 403) {
          throw NotAuthorized();
        } else {
          throw UnknownError(error.response?.statusMessage!);
        }
      });
    });
  }

  @override
  Future<String> downloadMakeOfflineSharedSpaceDocument(
      SharedSpaceId sharedSpaceId, 
      WorkGroupNodeId workGroupNodeId, 
      String workGroupNodeName, 
      DownloadPreviewType downloadPreviewType, 
      Token permanentToken, 
      Uri baseUrl) async
  {
    final appDocDir = await getApplicationSupportDirectory();
    final appDocPath = appDocDir.path;
    final savedDir = Directory('$appDocPath/shared_spaces');
    final hasExisted = await savedDir.exists();
    if (!hasExisted) {
      await savedDir.create();
    }
    
    var downloadUrl;
    if (downloadPreviewType == DownloadPreviewType.original) {
      downloadUrl = Endpoint.sharedSpaces
        .withPathParameter(sharedSpaceId.uuid)
        .withPathParameter('nodes')
        .downloadServicePath(workGroupNodeId.uuid)
        .generateDownloadUrl(baseUrl);
    } else {
      downloadUrl = Endpoint.sharedSpaces
        .withPathParameter(sharedSpaceId.uuid)
        .withPathParameter('nodes')
        .withPathParameter(workGroupNodeId.uuid)
        .withPathParameter(Endpoint.thumbnail)
        .withPathParameter(downloadPreviewType == DownloadPreviewType.image ? 'medium?base64=false' : 'pdf')
        .generateEndpointPath();
    }
    
    return _linShareDownloadManager.downloadFile(
      downloadUrl,
      Future.sync(() => savedDir),
      workGroupNodeName,
      permanentToken);
  }

  @override
  Future<WorkGroupNode> getRealSharedSpaceRootNode(SharedSpaceId sharedSpaceId, {bool hasTreePath = true}) {
    return Future.sync(() async {
      final workGroupNode = (await _linShareHttpClient.getWorkGroupNode(sharedSpaceId, sharedSpaceId.toWorkGroupNodeId(), hasTreePath: hasTreePath));

      if (workGroupNode is WorkGroupDocumentDto) {
        return workGroupNode.toWorkGroupDocument();
      }

      if (workGroupNode is WorkGroupNodeFolderDto) {
        return workGroupNode.toWorkGroupFolder();
      }

      return workGroupNode as WorkGroupNode;
    }).catchError((error) {
      _remoteExceptionThrower.throwRemoteException(error, handler: (DioError error) {
        if (error.response?.statusCode == 404) {
          throw SharedSpaceNodeNotFound();
        } else if (error.response?.statusCode == 403) {
          throw NotAuthorized();
        } else {
          throw UnknownError(error.response?.statusMessage!);
        }
      });
    });
  }

  @override
  Future<WorkGroupNode> moveWorkgroupNode(MoveWorkGroupNodeRequest moveRequest, SharedSpaceId sourceSharedSpaceId) {
    return Future.sync(() async {
      final workGroupNode = await _linShareHttpClient.moveWorkgroupNode(moveRequest.toMoveWorkGroupNodeBodyRequest(), sourceSharedSpaceId);

      if (workGroupNode is WorkGroupDocumentDto) return workGroupNode.toWorkGroupDocument();
      if (workGroupNode is WorkGroupNodeFolderDto) return workGroupNode.toWorkGroupFolder();

      return workGroupNode as WorkGroupNode;
    }).catchError((error) {
      _remoteExceptionThrower.throwRemoteException(error, handler: (DioError error) {
        if (error.response?.statusCode == 404) {
          throw WorkGroupNodeNotFoundException();
        } else if (error.response?.statusCode == 403) {
          throw NotAuthorized();
        } else {
          throw UnknownError(error.response?.statusMessage!);
        }
      });
    });
  }

  @override
  Future<List<WorkGroupNode?>> doAdvancedSearch(SharedSpaceId sharedSpaceId, AdvancedSearchRequest searchRequest) {
    return Future.sync(() async {
      return (await _linShareHttpClient.advanceSearchWorkGroupNodes(sharedSpaceId, searchRequest))
          .map<WorkGroupNode?>((workgroupNode) {
        if (workgroupNode is WorkGroupDocumentDto) return workgroupNode.toWorkGroupDocument();
        if (workgroupNode is WorkGroupNodeFolderDto) return workgroupNode.toWorkGroupFolder();
        return null;
      })
      .where((node) => node != null)
      .toList();
    }).catchError((error) {
      _remoteExceptionThrower.throwRemoteException(error, handler: (DioError error) {
        if (error.response?.statusCode == 404) {
          throw AdvanceSearchWorkgroupNodeNotFoundException();
        } else if (error.response?.statusCode == 403) {
          throw NotAuthorized();
        } else {
          throw UnknownError(error.response?.statusMessage!);
        }
      });
    });  }

  @override
  Future<bool> makeAvailableOfflineSharedSpaceDocument(
      SharedSpaceNodeNested? drive,
      SharedSpaceNodeNested sharedSpaceNodeNested,
      WorkGroupDocument workGroupDocument,
      String localPath,
      {List<TreeNode>? treeNodes}
  ) {
    throw UnimplementedError();
  }

  @override
  Future<WorkGroupDocument> getSharesSpaceDocumentOffline(WorkGroupNodeId workGroupNodeId) {
    throw UnimplementedError();
  }

  @override
  Future<bool> disableAvailableOfflineSharedSpaceDocument(
      DriveId? driveId,
      SharedSpaceId sharedSpaceId,
      WorkGroupNodeId? parentNodeId,
      WorkGroupNodeId workGroupNodeId,
      String localPath
  ) {
    throw UnimplementedError();
  }

  @override
  Future<List<WorkGroupNode>> getAllSharedSpaceDocumentOffline(SharedSpaceId sharedSpaceId, WorkGroupNodeId? parentNodeId) {
    throw UnimplementedError();
  }

  @override
  Future<bool> updateSharedSpaceDocumentOffline(WorkGroupDocument workGroupDocument, String localPath) {
    throw UnimplementedError();
  }

  @override
  Future<bool> deleteAllData() {
    throw UnimplementedError();
  }
}
