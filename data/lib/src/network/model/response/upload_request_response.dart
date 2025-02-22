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
import 'package:data/src/network/model/converter/datetime_converter.dart';
import 'package:data/src/network/model/converter/upload_request_id_converter.dart';
import 'package:data/src/util/attribute.dart';
import 'package:domain/domain.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'upload_request_response.g.dart';

@JsonSerializable()
@DatetimeConverter()
@UploadRequestIdConverter()
class UploadRequestResponse extends Equatable {
  UploadRequestResponse(
      this.uploadRequestId,
      this.label,
      this.body,
      this.creationDate,
      this.modificationDate,
      this.activationDate,
      this.notificationDate,
      this.expiryDate,
      this.protectedByPassword,
      this.enableNotification,
      this.collective,
      this.owner,
      this.status,
      this.usedSpace,
      this.nbrUploadedFiles,
      this.pristine,
      this.closed,
      this.locale,
      this.recipients,
      this.maxFileCount,
      this.maxDepositSize,
      this.maxFileSize,
      this.canClose,
      this.canDeleteDocument,
  );

  @JsonKey(name: Attribute.uuid)
  final UploadRequestId uploadRequestId;

  final String label;
  final String? body;
  final DateTime creationDate;
  final DateTime modificationDate;
  final DateTime activationDate;
  final DateTime notificationDate;
  final DateTime expiryDate;
  final bool protectedByPassword;
  final bool enableNotification;
  final bool collective;
  final GenericUserDto owner;
  final UploadRequestStatus status;
  final double usedSpace;
  final int nbrUploadedFiles;
  final bool pristine;
  final bool closed;
  final String locale;
  final List<GenericUserDto> recipients;
  final int? maxFileCount;
  final double? maxDepositSize;
  final double? maxFileSize;
  final bool? canClose;
  final bool? canDeleteDocument;

  factory UploadRequestResponse.fromJson(Map<String, dynamic> json) => _$UploadRequestResponseFromJson(json);

  Map<String, dynamic> toJson() => _$UploadRequestResponseToJson(this);

  @override
  List<Object?> get props => [
    uploadRequestId,
    label,
    body,
    creationDate,
    modificationDate,
    activationDate,
    notificationDate,
    expiryDate,
    protectedByPassword,
    enableNotification,
    collective,
    owner,
    status,
    usedSpace,
    nbrUploadedFiles,
    pristine,
    closed,
    locale,
    recipients,
    maxFileCount,
    maxDepositSize,
    maxFileSize,
    canClose,
    canDeleteDocument,
  ];
}

extension UploadRequestResponseExtension on UploadRequestResponse {
  UploadRequest toUploadRequest() {
    return UploadRequest(
      uploadRequestId,
      label,
      body,
      creationDate,
      modificationDate,
      activationDate,
      notificationDate,
      expiryDate,
      protectedByPassword,
      enableNotification,
      collective,
      owner.toGenericUser(),
      status,
      usedSpace,
      nbrUploadedFiles,
      pristine,
      closed,
      locale,
      recipients.map((e) => e.toGenericUser()).toList(),
      maxFileCount,
      maxDepositSize,
      maxFileSize,
      canClose,
      canDeleteDocument,
    );
  }
}
