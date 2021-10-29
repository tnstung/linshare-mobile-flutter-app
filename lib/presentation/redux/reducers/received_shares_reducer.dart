// LinShare is an open source filesharing software, part of the LinPKI software
// suite, developed by Linagora.
//
// Copyright (C) 2021 LINAGORA
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

import 'package:domain/domain.dart';
import 'package:linshare_flutter_app/presentation/redux/actions/received_share_action.dart';
import 'package:linshare_flutter_app/presentation/redux/states/received_share_state.dart';
import 'package:redux/redux.dart';

final receivedSharesReducer = combineReducers<ReceivedShareState>([
  TypedReducer<ReceivedShareState, StartReceivedShareLoadingAction>((ReceivedShareState state, _) => state.startLoadingState()),
  TypedReducer<ReceivedShareState, ReceivedShareAction>((ReceivedShareState state, ReceivedShareAction action) => state.sendViewState(viewState: action.viewState)),
  TypedReducer<ReceivedShareState, ReceivedShareGetAllReceivedSharesAction>((ReceivedShareState state, ReceivedShareGetAllReceivedSharesAction action) =>
      state.setReceivedShareList(
          action.viewState.fold(
                  (failure) => [],
                  (success) => (success is GetAllReceivedShareSuccess) ? success.receivedShares : []),
          viewState: action.viewState)),
  TypedReducer<ReceivedShareState, ReceivedShareSelectAction>((ReceivedShareState state, ReceivedShareSelectAction action) => state.selectReceivedShare(action.selectedReceivedShare)),
  TypedReducer<ReceivedShareState, ReceivedShareClearSelectedAction>((ReceivedShareState state, ReceivedShareClearSelectedAction action) => state.cancelSelectedReceivedShares()),
  TypedReducer<ReceivedShareState, ReceivedShareSelectAllAction>((ReceivedShareState state, ReceivedShareSelectAllAction action) => state.selectAllReceivedShares()),
  TypedReducer<ReceivedShareState, ReceivedShareUnselectAllAction>((ReceivedShareState state, ReceivedShareUnselectAllAction action) => state.unselectAllReceivedShares()),
  TypedReducer<ReceivedShareState, CleanReceivedShareStateAction>((ReceivedShareState state, _) => state.clearViewState()),
  TypedReducer<ReceivedShareState, ReceivedShareGetSorterAction>((ReceivedShareState state, ReceivedShareGetSorterAction action) =>
      state.setSorter(newSorter: action.sorter)),
  TypedReducer<ReceivedShareState, ReceivedShareSortReceivedShareAction>((ReceivedShareState state, ReceivedShareSortReceivedShareAction action) =>
      state.setReceivedSharesWithSorter(newReceivedShareList: action.receivedSharesList, newSorter: action.sorter)),
  TypedReducer<ReceivedShareState, ReceivedShareSetSearchResultAction>((ReceivedShareState state, ReceivedShareSetSearchResultAction action) =>
      state.setReceivedShareList(action.receivedSharesList)),
  TypedReducer<ReceivedShareState, ReceivedShareSetSyncOfflineMode>((ReceivedShareState state, ReceivedShareSetSyncOfflineMode action) =>
      state.setReceivedShareList(action.receivedShareList)),
]);
