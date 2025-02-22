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

import 'package:data/src/network/model/request/create_shared_space_node_folder_request.dart';
import 'package:dio/dio.dart';
import 'package:domain/domain.dart';
import 'package:domain/src/model/authentication/token.dart';
import 'package:domain/src/model/copy/copy_request.dart';
import 'package:domain/src/model/file_info.dart';
import 'package:domain/src/model/sharedspacedocument/work_group_node_id.dart';

abstract class SharedSpaceDocumentRepository {
  Future<UploadTaskId> uploadSharedSpaceDocument(
      FileInfo fileInfo,
      Token token,
      Uri baseUrl,
      SharedSpaceId sharedSpaceId,
      {WorkGroupNodeId? parentNodeId});

  Future<List<WorkGroupNode?>> getAllChildNodes(
      SharedSpaceId sharedSpaceId,
      {WorkGroupNodeId? parentNodeId});

  Future<List<WorkGroupNode>> copyToSharedSpace(
    CopyRequest copyRequest,
    SharedSpaceId destinationSharedSpaceId,
    {WorkGroupNodeId? destinationParentNodeId}
  );

  Future<WorkGroupNode> removeSharedSpaceNode(
    SharedSpaceId sharedSpaceId,
    WorkGroupNodeId sharedSpaceNodeId);

  Future<List<DownloadTaskId>> downloadNodes(
    List<WorkGroupNode> workgroupNodes,
    Token token,
    Uri baseUrl
  );

  Future<String> downloadNodeIOS(
    WorkGroupNode workgroupNode,
    Token token,
    Uri baseUrl,
    CancelToken cancelToken
  );

  Future<WorkGroupFolder> createSharedSpaceFolder(
    SharedSpaceId sharedSpaceId,
    CreateSharedSpaceNodeFolderRequest createSharedSpaceNodeRequest
  );

  Future<String> downloadPreviewWorkGroupDocument(
    WorkGroupDocument workGroupDocument,
    DownloadPreviewType downloadPreviewType,
    Token token,
    Uri baseUrl,
    CancelToken cancelToken
  );

  Future<WorkGroupNode> renameSharedSpaceNode(
    SharedSpaceId sharedSpaceId,
    WorkGroupNodeId sharedSpaceNodeId,
    RenameWorkGroupNodeRequest renameWorkGroupNodeRequest
  );

  Future<WorkGroupNode?> getWorkGroupNode(
    SharedSpaceId sharedSpaceId,
    WorkGroupNodeId workGroupNodeId,
    {bool hasTreePath});

  Future<bool> makeAvailableOfflineSharedSpaceDocument(
    SharedSpaceNodeNested? drive,
    SharedSpaceNodeNested sharedSpaceNodeNested,
    WorkGroupDocument workGroupDocument,
    String localPath,
    {List<TreeNode>? treeNodes});

  Future<String> downloadMakeOfflineSharedSpaceDocument(
    SharedSpaceId sharedSpaceId,
    WorkGroupNodeId workGroupNodeId,
    String workGroupNodeName,
    DownloadPreviewType downloadPreviewType,
    Token permanentToken,
    Uri baseUrl);

  Future<WorkGroupDocument?> getSharesSpaceDocumentOffline(WorkGroupNodeId workGroupNodeId);

  Future<bool> disableAvailableOfflineSharedSpaceDocument(
      DriveId? driveId,
      SharedSpaceId sharedSpaceId,
      WorkGroupNodeId? parentNodeId,
      WorkGroupNodeId workGroupNodeId,
      String localPath);

  Future<List<WorkGroupNode>> getAllSharedSpaceDocumentOffline(SharedSpaceId sharedSpaceId, WorkGroupNodeId? parentNodeId);

  Future<bool> updateSharedSpaceDocumentOffline(WorkGroupDocument workGroupDocument, String localPath);

  Future<bool> deleteAllData();

  Future<WorkGroupNode> getRealSharedSpaceRootNode(SharedSpaceId shareSpaceId, {bool hasTreePath = false});

  Future<WorkGroupNode> moveWorkgroupNode(MoveWorkGroupNodeRequest moveRequest, SharedSpaceId sourceSharedSpaceId);

  Future<List<WorkGroupNode?>> doAdvancedSearch(SharedSpaceId sharedSpaceId, AdvancedSearchRequest searchRequest);
}