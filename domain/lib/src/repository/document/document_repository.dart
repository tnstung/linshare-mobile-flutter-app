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

import 'dart:core';

import 'package:dio/dio.dart';
import 'package:domain/domain.dart';
import 'package:domain/src/model/authentication/token.dart';
import 'package:domain/src/model/document/document.dart';
import 'package:domain/src/model/document/document_id.dart';
import 'package:domain/src/model/file_info.dart';
import 'package:domain/src/model/generic_user.dart';
import 'package:domain/src/model/share/mailing_list_id.dart';
import 'package:domain/src/model/share/share.dart';
import 'package:domain/src/usecases/download_file/download_task_id.dart';
import 'package:domain/src/usecases/upload_file/file_upload_state.dart';

abstract class DocumentRepository {
  Future<UploadTaskId> upload(FileInfo fileInfo, Token token, Uri baseUrl);

  Future<List<Document>> getAll();

  Future<List<DownloadTaskId>> downloadDocuments(List<DocumentId> documentIds, Token token, Uri baseUrl);

  Future<List<Share>> share(List<DocumentId> documentIds, List<MailingListId> mailingListIds, List<GenericUser> recipients);

  Future<String> downloadDocumentIOS(Document document, Token token, Uri baseUrl, CancelToken cancelToken);

  Future<Document> remove(DocumentId documentId);

  Future<Document> rename(DocumentId documentId, RenameDocumentRequest renameDocumentRequest);

  Future<List<Document>> copyToMySpace(CopyRequest copyRequest);

  Future<String> downloadPreviewDocument(Document document, DownloadPreviewType downloadPreviewType, Token token, Uri baseUrl, CancelToken cancelToken);

  Future<DocumentDetails> getDocument(DocumentId documentId);

  Future<Document> editDescription(DocumentId documentId, EditDescriptionDocumentRequest request);

  Future<Document?> getDocumentOffline(DocumentId documentId);

  Future<bool> updateDocumentOffline(Document document, String localPath);

  Future<bool> makeAvailableOffline(Document document, String localPath);

  Future<bool> disableAvailableOffline(DocumentId documentId, String localPath);

  Future<List<Document>> getAllDocumentOffline();

  Future<String> downloadMakeOfflineDocument(DocumentId documentId, String documentName, DownloadPreviewType downloadPreviewType, Token permanentToken, Uri baseUrl);

  Future<bool> deleteAllData();
}
