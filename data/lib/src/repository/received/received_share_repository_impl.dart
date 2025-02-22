/*
 * LinShare is an open source filesharing software, part of the LinPKI software
 * suite, developed by Linagora.
 *
 * Copyright (C) 2021 LINAGORA
 *
 * This program is free software: you can redistribute it and/or modify it under the
 * terms of the GNU Affero General Public License as published by the Free Software
 * Foundation, either version 3 of the License, or (at your option) any later version,
 * provided you comply with the Additional Terms applicable for LinShare software by
 * Linagora pursuant to Section 7 of the GNU Affero General Public License,
 * subsections (b), (c), and (e), pursuant to which you must notably (i) retain the
 * display in the interface of the “LinShare™” trademark/logo, the "Libre & Free" mention,
 * the words “You are using the Free and Open Source version of LinShare™, powered by
 * Linagora © 2009–2021. Contribute to Linshare R&D by subscribing to an Enterprise
 * offer!”. You must also retain the latter notice in all asynchronous messages such as
 * e-mails sent with the Program, (ii) retain all hypertext links between LinShare and
 * http://www.linshare.org, between linagora.com and Linagora, and (iii) refrain from
 * infringing Linagora intellectual property rights over its trademarks and commercial
 * brands. Other Additional Terms apply, see
 * <http://www.linshare.org/licenses/LinShare-License_AfferoGPL-v3.pdf>
 * for more details.
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY
 * WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for
 * more details.
 * You should have received a copy of the GNU Affero General Public License and its
 * applicable Additional Terms for LinShare along with this program. If not, see
 * <http://www.gnu.org/licenses/> for the GNU Affero General Public License version
 *  3 and <http://www.linshare.org/licenses/LinShare-License_AfferoGPL-v3.pdf> for
 *  the Additional Terms applicable to LinShare software.
 */

import 'package:data/data.dart';
import 'package:data/src/datasource/received_share_datasource.dart';
import 'package:dio/src/cancel_token.dart';
import 'package:domain/domain.dart';

class ReceivedShareRepositoryImpl extends ReceivedShareRepository {
  final Map<DataSourceType, ReceivedShareDataSource> _receivedShareDataSources;

  ReceivedShareRepositoryImpl(this._receivedShareDataSources);

  @override
  Future<List<ReceivedShare>> getAllReceivedShares() {
    return _receivedShareDataSources[DataSourceType.network]!.getAllReceivedShares();
  }

  @override
  Future<List<DownloadTaskId>> downloadReceivedShares(List<ShareId> shareIds, Token token, Uri baseUrl) {
    return _receivedShareDataSources[DataSourceType.network]!.downloadReceivedShares(shareIds, token, baseUrl);
  }

  @override
  Future<String> downloadPreviewReceivedShare(ReceivedShare receivedShare, DownloadPreviewType downloadPreviewType, Token permanentToken, Uri baseUrl, CancelToken cancelToken) {
    return _receivedShareDataSources[DataSourceType.network]!.downloadPreviewReceivedShare(receivedShare, downloadPreviewType, permanentToken, baseUrl, cancelToken);
  }

  @override
  Future<ReceivedShare> getReceivedShare(ShareId shareId) {
    return _receivedShareDataSources[DataSourceType.network]!.getReceivedShare(shareId);
  }

  @override
  Future<bool> makeAvailableOffline(ReceivedShare receivedShare, String localPath) {
    return _receivedShareDataSources[DataSourceType.local]!.makeAvailableOffline(receivedShare, localPath);
  }

  @override
  Future<String> downloadToMakeOffline(ShareId shareId, String name, DownloadPreviewType downloadPreviewType, Token permanentToken, Uri baseUrl) {
    return _receivedShareDataSources[DataSourceType.network]!.downloadToMakeOffline(shareId, name, downloadPreviewType, permanentToken, baseUrl);
  }

  @override
  Future<ReceivedShare> remove(ShareId shareId) {
    return _receivedShareDataSources[DataSourceType.network]!.remove(shareId);
  }

  @override
  Future<String> exportReceivedShare(
      ReceivedShare receivedShare,
      Token permanentToken,
      Uri baseUrl,
      CancelToken cancelToken
  ) {
    return _receivedShareDataSources[DataSourceType.network]!.exportReceivedShare(
      receivedShare,
      permanentToken,
      baseUrl,
      cancelToken);
  }

  @override
  Future<List<ReceivedShare>> getAllReceivedShareOffline() {
    return _receivedShareDataSources[DataSourceType.local]!.getAllReceivedShareOffline();
  }

  @override
  Future<ReceivedShare?> getReceivedShareOffline(ShareId shareId) {
    return _receivedShareDataSources[DataSourceType.local]!.getReceivedShareOffline(shareId);
  }

  @override
  Future<bool> disableOffline(ShareId shareId, String localPath) {
    return _receivedShareDataSources[DataSourceType.local]!.disableOffline(shareId, localPath);
  }
}
