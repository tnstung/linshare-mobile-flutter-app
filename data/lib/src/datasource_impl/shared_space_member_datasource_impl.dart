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

import 'package:data/data.dart';
import 'package:data/src/network/linshare_http_client.dart';
import 'package:data/src/network/remote_exception_thrower.dart';
import 'package:dio/dio.dart';
import 'package:domain/domain.dart';

class SharedSpaceMemberDataSourceImpl implements SharedSpaceMemberDataSource {
  final LinShareHttpClient _linShareHttpClient;
  final RemoteExceptionThrower _remoteExceptionThrower;

  SharedSpaceMemberDataSourceImpl(this._linShareHttpClient, this._remoteExceptionThrower);

  @override
  Future<List<SharedSpaceMember>> getMembers(SharedSpaceId sharedSpaceId) {
    return Future.sync(() async {
        return (await _linShareHttpClient.getSharedSpaceMembers(sharedSpaceId)).map((memberDto) => memberDto.toSharedSpaceMember()).toList();
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
  Future<SharedSpaceMember> addMember(SharedSpaceId sharedSpaceId, AddSharedSpaceMemberRequest request) {
    return Future.sync(() async {
      final sharedSpaceMember = await _linShareHttpClient.addSharedSpaceMember(sharedSpaceId, request);
      return sharedSpaceMember.toSharedSpaceMember();
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
  Future<SharedSpaceMember> updateMemberRole(SharedSpaceId sharedSpaceId, UpdateSharedSpaceMemberRequest request) {
    return Future.sync(() async {
      final sharedSpaceMember = await _linShareHttpClient.updateRoleSharedSpaceMember(sharedSpaceId, request);
      return sharedSpaceMember.toSharedSpaceMember();
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
  Future<SharedSpaceMember> deleteMember(SharedSpaceId sharedSpaceId, SharedSpaceMemberId sharedSpaceMemberId) {
    return Future.sync(() async {
      final sharedSpaceMember = await _linShareHttpClient.deleteSharedSpaceMember(
          sharedSpaceId,
          sharedSpaceMemberId);
      return sharedSpaceMember.toSharedSpaceMember();
    }).catchError((error) {
      _remoteExceptionThrower.throwRemoteException(error,
          handler: (DioError error) {
        if (error.response?.statusCode == 404) {
          throw SharedSpaceMemberNotFound();
        } else if (error.response?.statusCode == 403) {
          throw NotAuthorized();
        } else {
          throw UnknownError(error.response?.statusMessage!);
        }
      });
    });
  }

  @override
  Future<SharedSpaceMember> updateDriveMemberRole(SharedSpaceId sharedSpaceId, UpdateDriveMemberRequest request, {bool? isOverrideRoleForAll}) {
    return Future.sync(() async {
      final driveMember = await _linShareHttpClient.updateRoleDriveMember(sharedSpaceId, request, isOverrideRoleForAll: isOverrideRoleForAll);
      return driveMember.toSharedSpaceMember();
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
}
