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

import 'dart:async';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:data/data.dart';
import 'package:dio/dio.dart';
import 'package:domain/domain.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:linshare_flutter_app/presentation/localizations/app_localizations.dart';
import 'package:linshare_flutter_app/presentation/model/file/selectable_element.dart';
import 'package:linshare_flutter_app/presentation/model/file/share_presentation_file.dart';
import 'package:linshare_flutter_app/presentation/model/item_selection_type.dart';
import 'package:linshare_flutter_app/presentation/redux/actions/received_share_action.dart';
import 'package:linshare_flutter_app/presentation/redux/actions/ui_action.dart';
import 'package:linshare_flutter_app/presentation/redux/online_thunk_action.dart';
import 'package:linshare_flutter_app/presentation/redux/states/app_state.dart';
import 'package:linshare_flutter_app/presentation/redux/states/received_share_state.dart';
import 'package:linshare_flutter_app/presentation/redux/states/ui_state.dart';
import 'package:linshare_flutter_app/presentation/util/router/app_navigation.dart';
import 'package:linshare_flutter_app/presentation/util/router/route_paths.dart';
import 'package:linshare_flutter_app/presentation/view/context_menu/context_menu_builder.dart';
import 'package:linshare_flutter_app/presentation/view/downloading_file/downloading_file_builder.dart';
import 'package:linshare_flutter_app/presentation/view/header/context_menu_header_builder.dart';
import 'package:linshare_flutter_app/presentation/view/header/more_action_bottom_sheet_header_builder.dart';
import 'package:linshare_flutter_app/presentation/view/header/simple_bottom_sheet_header_builder.dart';
import 'package:linshare_flutter_app/presentation/view/modal_sheets/confirm_modal_sheet_builder.dart';
import 'package:linshare_flutter_app/presentation/view/order_by/order_by_dialog_bottom_sheet.dart';
import 'package:linshare_flutter_app/presentation/widget/base/base_viewmodel.dart';
import 'package:linshare_flutter_app/presentation/widget/destination_picker/destination_picker_action/copy_destination_picker_action.dart';
import 'package:linshare_flutter_app/presentation/widget/destination_picker/destination_picker_action/negative_destination_picker_action.dart';
import 'package:linshare_flutter_app/presentation/widget/destination_picker/destination_picker_arguments.dart';
import 'package:linshare_flutter_app/presentation/widget/received_share_details/received_share_details_arguments.dart';
import 'package:linshare_flutter_app/presentation/widget/shared_space_document/shared_space_document_arguments.dart';
import 'package:open_file/open_file.dart' as open_file;
import 'package:permission_handler/permission_handler.dart';
import 'package:redux/src/store.dart';
import 'package:redux_thunk/redux_thunk.dart';
import 'package:share/share.dart' as share_library;

class ReceivedShareViewModel extends BaseViewModel {
  final GetAllReceivedSharesInteractor _getAllReceivedInteractor;
  final AppNavigation _appNavigation;
  final CopyMultipleFilesFromReceivedSharesToMySpaceInteractor _copyMultipleFilesFromReceivedSharesToMySpaceInteractor;
  final DownloadReceivedSharesInteractor _downloadReceivedSharesInteractor;
  final DownloadPreviewReceivedShareInteractor _downloadPreviewReceivedShareInteractor;
  final GetSorterInteractor _getSorterInteractor;
  final SaveSorterInteractor _saveSorterInteractor;
  final SortInteractor _sortInteractor;
  final DeviceManager _deviceManager;
  final RemoveMultipleReceivedSharesInteractor _removeMultipleReceivedShareInteractor;
  final ExportMultipleReceivedSharesInteractor _exportMultipleReceivedSharesInteractor;
  final CopyMultipleFilesToSharedSpaceInteractor _copyMultipleFilesToSharedSpaceInteractor;
  final MakeReceivedShareOfflineInteractor _makeReceivedShareOfflineInteractor;
  final DisableOfflineReceivedShareInteractor _disableOfflineReceivedShareInteractor;

  List<ReceivedShare> _receivedSharesList = [];
  final SearchReceivedSharesInteractor _searchReceivedSharesInteractor;

  late StreamSubscription _storeStreamSubscription;

  SearchQuery _searchQuery = SearchQuery('');
  SearchQuery get searchQuery  => _searchQuery;

  ReceivedShareViewModel(
      Store<AppState> store,
      this._getAllReceivedInteractor,
      this._appNavigation,
      this._copyMultipleFilesFromReceivedSharesToMySpaceInteractor,
      this._downloadReceivedSharesInteractor,
      this._downloadPreviewReceivedShareInteractor,
      this._getSorterInteractor,
      this._saveSorterInteractor,
      this._sortInteractor,
      this._searchReceivedSharesInteractor,
      this._deviceManager,
      this._removeMultipleReceivedShareInteractor,
      this._exportMultipleReceivedSharesInteractor,
      this._copyMultipleFilesToSharedSpaceInteractor,
      this._makeReceivedShareOfflineInteractor,
      this._disableOfflineReceivedShareInteractor,
  ) : super(store) {
    _storeStreamSubscription = store.onChange.listen((event) {
      event.receivedShareState.viewState.fold(
         (failure) => null,
         (success) {
            if (success is SearchReceivedSharesNewQuery && event.uiState.searchState.searchStatus == SearchStatus.ACTIVE) {
              _search(success.searchQuery);
            } else if (success is DisableSearchViewState) {
              store.dispatch((ReceivedShareSetSearchResultAction(_receivedSharesList)));
              _searchQuery = SearchQuery('');
            } else if (success is RemoveReceivedShareViewState ||
                success is RemoveMultipleReceivedSharesAllSuccessViewState ||
                success is RemoveMultipleReceivedSharesHasSomeFilesFailedViewState ||
                success is DisableOfflineReceivedShareViewState) {
              getAllReceivedShare();
            }
      });
    });
  }

  void _search(SearchQuery searchQuery) {
    _searchQuery = searchQuery;
    if (searchQuery.value.isNotEmpty) {
      store.dispatch(_searchReceivedSharesAction(_receivedSharesList, searchQuery));
    } else {
      store.dispatch(ReceivedShareSetSearchResultAction([]));
    }
  }

  ThunkAction<AppState> _searchReceivedSharesAction(List<ReceivedShare> receivedSharesList, SearchQuery searchQuery) {
    return (Store<AppState> store) async {
      await _searchReceivedSharesInteractor.execute(receivedSharesList, searchQuery).then((result) => result.fold(
              (failure) {
                if (_isInSearchState()) {
                  store.dispatch(ReceivedShareSetSearchResultAction([]));
                }
              },
              (success) {
                if (_isInSearchState()) {
                  store.dispatch(ReceivedShareSetSearchResultAction(success is SearchReceivedSharesSuccess ? success.receivedSharesList : []));
                }
              })
      );
    };
  }

  bool _isInSearchState() {
    return store.state.uiState.isInSearchState();
  }

  void getAllReceivedShare() {
    store.dispatch(_getAllReceivedShareAction());
  }

  ThunkAction<AppState> _getAllReceivedShareAction() {
    return (Store<AppState> store) async {
      store.dispatch(StartReceivedShareLoadingAction());
      await _getAllReceivedInteractor.execute().then((result) => result.fold(
        (failure) {
          store.dispatch(ReceivedShareGetAllReceivedSharesAction(Left(failure)));
          _receivedSharesList = [];
          store.dispatch(_sortFilesAction(store.state.receivedShareState.sorter));
        },
        (success) {
          store.dispatch(ReceivedShareGetAllReceivedSharesAction(Right(success)));
          _receivedSharesList = success is GetAllReceivedShareSuccess ? success.receivedShares : [];
          store.dispatch(_sortFilesAction(store.state.receivedShareState.sorter));
        })
      );
    };
  }

  void openContextMenu(BuildContext context, ReceivedShare share, List<Widget> actionTiles, {Widget? footerAction}) {
    store.dispatch(_handleContextMenuAction(context, share, actionTiles, footerAction: footerAction));
  }

  ThunkAction<AppState> _handleContextMenuAction(
      BuildContext context,
      ReceivedShare share,
      List<Widget> actionTiles,
      {Widget? footerAction}) {
    return (Store<AppState> store) async {
      ContextMenuBuilder(context)
          .addHeader(ContextMenuHeaderBuilder(
            Key('context_menu_header'),
            SharePresentationFile.fromShare(share)).build())
          .addTiles(actionTiles)
          .addFooter(footerAction ?? SizedBox.shrink())
          .build();
      store.dispatch(ReceivedShareAction(Right(ReceivedShareContextMenuItemViewState(share))));
    };
  }

  void copyToMySpace(List<ReceivedShare> shares, {bool fromMoreAction = false, ItemSelectionType itemSelectionType = ItemSelectionType.single}) {
    if (itemSelectionType == ItemSelectionType.single || fromMoreAction) {
      _appNavigation.popBack();
    }

    if (itemSelectionType == ItemSelectionType.multiple) {
      cancelSelection();
    }

    store.dispatch(_copyToMySpaceAction(shares));
  }

  OnlineThunkAction _copyToMySpaceAction(List<ReceivedShare> shares) {
    return OnlineThunkAction((Store<AppState> store) async {
      await _copyMultipleFilesFromReceivedSharesToMySpaceInteractor.execute(shares)
        .then((result) => result.fold(
          (failure) => store.dispatch(ReceivedShareAction(Left(failure))),
          (success) => store.dispatch(ReceivedShareAction(Right(success)))));
    });
  }

  void selectItem(SelectableElement<ReceivedShare> selectedReceivedShare) {
    store.dispatch(ReceivedShareSelectAction(selectedReceivedShare));
  }

  void toggleSelectAllReceivedShares() {
    if (store.state.receivedShareState.isAllReceivedSharesSelected()) {
      store.dispatch(ReceivedShareUnselectAllAction());
    } else {
      store.dispatch(ReceivedShareSelectAllAction());
    }
  }

  void cancelSelection() {
    store.dispatch(ReceivedShareClearSelectedAction());
  }

  void downloadFileClick(List<ShareId> shareIds, {ItemSelectionType itemSelectionType = ItemSelectionType.single}) {
    store.dispatch(_handleDownloadFile(shareIds, itemSelectionType: itemSelectionType));
  }

  OnlineThunkAction _handleDownloadFile(List<ShareId> shareIds, {ItemSelectionType itemSelectionType = ItemSelectionType.single}) {
    return OnlineThunkAction((Store<AppState> store) async {
      final needRequestPermission = await _deviceManager.isNeedRequestStoragePermissionOnAndroid();
      if(Platform.isAndroid && needRequestPermission) {
        final status = await Permission.storage.status;
        switch (status) {
          case PermissionStatus.granted:
            _download(shareIds, itemSelectionType: itemSelectionType);
            break;
          case PermissionStatus.permanentlyDenied:
            _appNavigation.popBack();
            break;
          default:
            {
              final requested = await Permission.storage.request();
              switch (requested) {
                case PermissionStatus.granted:
                  _download(shareIds, itemSelectionType: itemSelectionType);
                  break;
                default:
                  _appNavigation.popBack();
                  break;
              }
            }
        }
      } else {
        _download(shareIds, itemSelectionType: itemSelectionType);
      }
    });
  }

  void _download(List<ShareId> shareIds, {ItemSelectionType itemSelectionType = ItemSelectionType.single}) {
    store.dispatch(_downloadFileAction(shareIds));
    _appNavigation.popBack();
    if (itemSelectionType == ItemSelectionType.multiple) {
      cancelSelection();
    }
  }

  OnlineThunkAction _downloadFileAction(List<ShareId> shareIds) {
    return OnlineThunkAction((Store<AppState> store) async {
      await _downloadReceivedSharesInteractor.execute(shareIds).then((result) => result.fold(
        (failure) => store.dispatch(ReceivedShareAction(Left(failure))),
        (success) => store.dispatch(ReceivedShareAction(Right(success)))));
    });
  }

  void _showPrepareToPreviewFileDialog(BuildContext context, ReceivedShare receivedShare, CancelToken cancelToken) {
    showCupertinoDialog(
      context: context,
      builder: (_) => DownloadingFileBuilder(cancelToken, _appNavigation)
        .key(Key('prepare_to_preview_file_dialog'))
        .title(AppLocalizations.of(context).preparing_to_preview_file)
        .content(AppLocalizations.of(context).downloading_file(receivedShare.name))
        .actionText(AppLocalizations.of(context).cancel)
        .build()
    );
  }

  void onClickPreviewFile(BuildContext context, ReceivedShare receivedShare) {
    store.dispatch(OnlineThunkAction((Store<AppState> store) async {
      _previewReceivedShare(context, receivedShare);
    }));
  }

  void _previewReceivedShare(BuildContext context, ReceivedShare receivedShare) {
    _appNavigation.popBack();
    final canPreviewReceivedShare = Platform.isIOS ? receivedShare.mediaType.isIOSSupportedPreview() : receivedShare.mediaType.isAndroidSupportedPreview();
    if (canPreviewReceivedShare || (receivedShare.hasThumbnail)) {
      final cancelToken = CancelToken();
      _showPrepareToPreviewFileDialog(context, receivedShare, cancelToken);

      var downloadPreviewType = DownloadPreviewType.original;
      if (receivedShare.mediaType.isImageFile()) {
        downloadPreviewType = DownloadPreviewType.image;
      } else if (!canPreviewReceivedShare) {
        downloadPreviewType = DownloadPreviewType.thumbnail;
      }
      store.dispatch(_handleDownloadPreviewReceivedShare(receivedShare, downloadPreviewType, cancelToken));
    } else {
      store.dispatch(ReceivedShareAction(Left(NoReceivedSharePreviewAvailable())));
    }
  }

  OnlineThunkAction _handleDownloadPreviewReceivedShare(ReceivedShare receivedShare, DownloadPreviewType downloadPreviewType, CancelToken cancelToken) {
    return OnlineThunkAction((Store<AppState> store) async {
      await _downloadPreviewReceivedShareInteractor
          .execute(receivedShare, downloadPreviewType, cancelToken)
          .then((result) => result.fold(
              (failure) {
                if (failure is DownloadPreviewReceivedShareFailure && !(failure.downloadPreviewException is CancelDownloadFileException)) {
                  store.dispatch(ReceivedShareAction(Left(NoReceivedSharePreviewAvailable())));
                }
              },
              (success) {
                if (success is DownloadPreviewReceivedShareViewState) {
                  _openDownloadedPreviewReceivedShare(receivedShare, success);
                }
          }));
    });
  }

  void _openDownloadedPreviewReceivedShare(ReceivedShare receivedShare, DownloadPreviewReceivedShareViewState viewState) async {
    _appNavigation.popBack();

    final openResult = await open_file.OpenFile.open(
        viewState.filePath,
        type: Platform.isAndroid ? receivedShare.mediaType.mimeType : null,
        uti:  Platform.isIOS ? receivedShare.mediaType.getDocumentUti().value : null);

    if (openResult.type != open_file.ResultType.done) {
      store.dispatch(ReceivedShareAction(Left(NoReceivedSharePreviewAvailable())));
    }
  }

  void getSorterAndAllReceivedSharesAction() {
    store.dispatch(_getSorterAndAllReceivedSharesAction());
  }

  ThunkAction<AppState> _getSorterAndAllReceivedSharesAction() {
    return (Store<AppState> store) async {
      store.dispatch(StartReceivedShareLoadingAction());

      await Future.wait([
        _getSorterInteractor.execute(OrderScreen.receivedShares),
        _getAllReceivedInteractor.execute()
      ]).then((response) async {
        response[0].fold((failure) {
          store.dispatch(ReceivedShareGetSorterAction(Sorter.fromOrderScreen(OrderScreen.receivedShares)));
        }, (success) {
          store.dispatch(ReceivedShareGetSorterAction(success is GetSorterSuccess
              ? success.sorter
              : Sorter.fromOrderScreen(OrderScreen.receivedShares)));
        });
        response[1].fold((failure) {
          store.dispatch(ReceivedShareGetAllReceivedSharesAction(Left(failure)));
          _receivedSharesList = [];
        }, (success) {
          store.dispatch(ReceivedShareGetAllReceivedSharesAction(Right(success)));
          _receivedSharesList =
              success is GetAllReceivedShareSuccess ? success.receivedShares : [];
        });
      });

      store.dispatch(_sortFilesAction(store.state.receivedShareState.sorter));
    };
  }

  ThunkAction<AppState> _sortFilesAction(Sorter sorter) {
    return (Store<AppState> store) async {
      await Future.wait([
        _saveSorterInteractor.execute(sorter),
        _sortInteractor.execute(_receivedSharesList, sorter)
      ]).then((response) => response[1].fold((failure) {
            _receivedSharesList = [];
            store.dispatch(ReceivedShareSortReceivedShareAction(_receivedSharesList, sorter));
          }, (success) {
            _receivedSharesList =
                success is GetAllReceivedShareSuccess ? success.receivedShares : [];
            store.dispatch(ReceivedShareSortReceivedShareAction(_receivedSharesList, sorter));
          }));
    };
  }

  void openPopupMenuSorter(BuildContext context, Sorter currentSorter) {
    ContextMenuBuilder(context)
        .addHeader(SimpleBottomSheetHeaderBuilder(Key('order_by_menu_header'))
            .addLabel(AppLocalizations.of(context).order_by)
            .build())
        .addTiles(OrderByDialogBottomSheetBuilder(context, currentSorter)
            .onSelectSorterAction((sorterSelected) => _sortFiles(sorterSelected))
            .build())
        .build();
  }

  void _sortFiles(Sorter sorter) {
    final newSorter = store.state.receivedShareState.sorter == sorter ? sorter.getSorterByOrderType(sorter.orderType) : sorter;
    _appNavigation.popBack();
    store.dispatch(_sortFilesAction(newSorter));
  }

  void removeReceivedShare(
      BuildContext context,
      List<ReceivedShare> receivedShares,
      {ItemSelectionType itemSelectionType = ItemSelectionType.single}
  ) {
    _appNavigation.popBack();
    if (itemSelectionType == ItemSelectionType.multiple) {
      cancelSelection();
    }

    if (receivedShares.isNotEmpty) {
      final deleteTitle = AppLocalizations.of(context)
        .are_you_sure_you_want_to_delete_multiple(receivedShares.length, receivedShares.first.name);

      ConfirmModalSheetBuilder(_appNavigation)
        .key(Key('delete_received_share_confirm_modal'))
        .title(deleteTitle)
        .cancelText(AppLocalizations.of(context).cancel)
        .onConfirmAction(AppLocalizations.of(context).delete, (_) {
            _appNavigation.popBack();
            if (itemSelectionType == ItemSelectionType.multiple) {
              cancelSelection();
            }
            store.dispatch(_removeReceivedShareAction(receivedShares.map((receivedShare) => receivedShare.shareId).toList()));
          })
        .show(context);
    }
  }

  OnlineThunkAction _removeReceivedShareAction(List<ShareId> shareIds) {
    return OnlineThunkAction((Store<AppState> store) async {
      await _removeMultipleReceivedShareInteractor.execute(shareIds: shareIds)
        .then((result) => result.fold(
          (failure) => store.dispatch(ReceivedShareAction(Left(failure))),
          (success) => store.dispatch(ReceivedShareAction(Right(success)))));
    });
  }

  void exportFile(BuildContext context, List<ReceivedShare> receivedShares, {ItemSelectionType itemSelectionType = ItemSelectionType.single}) {
    _appNavigation.popBack();
    if (itemSelectionType == ItemSelectionType.multiple) {
      cancelSelection();
    }
    final cancelToken = CancelToken();
    _showDownloadingFileDialog(context, receivedShares, cancelToken);
    store.dispatch(_exportFileAction(receivedShares, cancelToken));
  }

  void _showDownloadingFileDialog(BuildContext context, List<ReceivedShare> receivedShares, CancelToken cancelToken) {
    final downloadMessage = receivedShares.length <= 1
      ? AppLocalizations.of(context).downloading_file(receivedShares.first.name)
      : AppLocalizations.of(context).downloading_files(receivedShares.length);

    showCupertinoDialog(
      context: context,
      builder: (_) => DownloadingFileBuilder(cancelToken, _appNavigation)
        .key(Key('downloading_file_dialog'))
        .title(AppLocalizations.of(context).preparing_to_export)
        .content(downloadMessage)
        .actionText(AppLocalizations.of(context).cancel)
        .build());
  }

  ThunkAction<AppState> _exportFileAction(List<ReceivedShare> receivedShares, CancelToken cancelToken) {
    return (Store<AppState> store) async {
      await _exportMultipleReceivedSharesInteractor.execute(
          receivedShares: receivedShares,
          cancelToken: cancelToken
      ).then((result) => result.fold(
        (failure) => store.dispatch(_exportFileFailureAction(failure)),
        (success) => store.dispatch(_exportFileSuccessAction(success))));
    };
  }

  ThunkAction<AppState> _exportFileSuccessAction(Success success) {
    return (Store<AppState> store) async {
      _appNavigation.popBack();
      store.dispatch(ReceivedShareAction(Right(success)));
      if (success is ExportReceivedShareViewState) {
        await share_library.Share.shareFiles([success.filePath]);
      } else if (success is ExportReceivedSharesAllSuccessViewState) {
        await share_library.Share.shareFiles(success.resultList
          .map((result) => ((result.getOrElse(() => IdleState()) as ExportReceivedShareViewState).filePath))
          .toList());
      } else if (success is ExportReceivedSharesHasSomeFilesFailureViewState) {
        await share_library.Share.shareFiles(success.resultList
          .map((result) => result.fold(
            (failure) => '',
            (success) => ((success as ExportReceivedShareViewState).filePath)))
          .toList());
      }
    };
  }

  ThunkAction<AppState> _exportFileFailureAction(Failure failure) {
    return (Store<AppState> store) async {
      if (failure is ExportReceivedShareFailure && !(failure.exception is CancelDownloadFileException)) {
        _appNavigation.popBack();
      }
      store.dispatch(ReceivedShareAction(Left(failure)));
    };
  }

  void openMoreActionBottomMenu(BuildContext context, List<ReceivedShare> receivedShares, List<Widget> actionTiles, Widget footerAction) {
    ContextMenuBuilder(context)
      .addHeader(MoreActionBottomSheetHeaderBuilder(
            context,
            Key('more_action_menu_header'),
            receivedShares.map((receivedShare) => SharePresentationFile.fromShare(receivedShare)).toList())
         .build())
      .addTiles(actionTiles)
      .addFooter(footerAction)
      .build();
  }

  void clickOnCopyToAWorkGroup(
      BuildContext context,
      List<ReceivedShare> receivedShares,
      {ItemSelectionType itemSelectionType = ItemSelectionType.single}
  ) {
    store.dispatch(OnlineThunkAction((Store<AppState> store) async {
      _copyToAWorkgroup(context, receivedShares, itemSelectionType: itemSelectionType);
    }));
  }

  void _copyToAWorkgroup(
      BuildContext context,
      List<ReceivedShare> receivedShares,
      {ItemSelectionType itemSelectionType = ItemSelectionType.single}
  ) {
    _appNavigation.popBack();
    if (itemSelectionType == ItemSelectionType.multiple) {
      cancelSelection();
    }

    final cancelAction = NegativeDestinationPickerAction(
        context,
        label: AppLocalizations.of(context).cancel.toUpperCase());
    cancelAction.onDestinationPickerActionClick((_) => _appNavigation.popBack());

    final copyAction = CopyDestinationPickerAction(context);
    copyAction.onDestinationPickerActionClick((data) {
      _appNavigation.popBack();
      getAllReceivedShare();
      store.dispatch(ReceivedShareAction(Right(DisableSearchViewState())));

      if (data is SharedSpaceDocumentArguments) {
        store.dispatch(_copyToWorkgroupAction(receivedShares, data));
      }
    });

    _appNavigation.push(
      RoutePaths.destinationPicker,
      arguments: DestinationPickerArguments(
        actionList: [copyAction, cancelAction],
        operator: Operation.copyFromReceivedShare));
  }

  ThunkAction<AppState> _copyToWorkgroupAction(
      List<ReceivedShare> receivedShares,
      SharedSpaceDocumentArguments sharedSpaceDocumentArguments
  ) {
    return (Store<AppState> store) async {
      final parentNodeId = sharedSpaceDocumentArguments.workGroupFolder != null
          ? sharedSpaceDocumentArguments.workGroupFolder?.workGroupNodeId
          : null;
      await _copyMultipleFilesToSharedSpaceInteractor.execute(
          receivedShares.map((receivedShare) => receivedShare.toCopyRequest()).toList(),
          sharedSpaceDocumentArguments.sharedSpaceNode.sharedSpaceId,
          destinationParentNodeId: parentNodeId
      ).then((result) => result.fold(
          (failure) => store.dispatch(ReceivedShareAction(Left(failure))),
          (success) => store.dispatch(ReceivedShareAction(Right(success)))));
    };
  }

  void makeAvailableOffline(BuildContext context, ReceivedShare receivedShare, int position) {
    _appNavigation.popBack();

    _receivedSharesList[position] = receivedShare.toSyncOffline(syncOfflineState: SyncOfflineState.waiting);
    store.dispatch(ReceivedShareSetSyncOfflineMode(_receivedSharesList));

    store.dispatch(_makeAvailableOfflineAction(receivedShare, position));
  }

  OnlineThunkAction _makeAvailableOfflineAction(ReceivedShare receivedShare, int position) {
    return OnlineThunkAction((Store<AppState> store) async {
      await _makeReceivedShareOfflineInteractor.execute(receivedShare)
        .then((result) => result.fold(
          (failure) {
            _receivedSharesList[position] = receivedShare.toSyncOffline(syncOfflineState: SyncOfflineState.none);
            store.dispatch(ReceivedShareSetSyncOfflineMode(_receivedSharesList));

            store.dispatch(ReceivedShareAction(Left(failure)));
          },
          (success) {
            if (success is MakeAvailableOfflineReceivedShareViewState && success.result == OfflineModeActionResult.successful) {
              _receivedSharesList[position] = receivedShare.toSyncOffline(localPath: success.localPath, syncOfflineState: SyncOfflineState.completed);
              store.dispatch(ReceivedShareSetSyncOfflineMode(_receivedSharesList));

              store.dispatch(ReceivedShareAction(Right(success)));
            } else {
              _receivedSharesList[position] = receivedShare.toSyncOffline(syncOfflineState: SyncOfflineState.none);
              store.dispatch(ReceivedShareSetSyncOfflineMode(_receivedSharesList));

              store.dispatch(ReceivedShareAction(Left(CannotOfflineReceivedShare())));
            }
          }
        )
      );
    });
  }

  void disableOffline(BuildContext context, ReceivedShare receivedShare) {
    _appNavigation.popBack();
    store.dispatch(_disableOfflineAction(context, receivedShare));
  }

  ThunkAction<AppState> _disableOfflineAction(BuildContext context, ReceivedShare receivedShare) {
    return (Store<AppState> store) async {
      await _disableOfflineReceivedShareInteractor
        .execute(receivedShare)
        .then((result) => result.fold(
          (failure) => store.dispatch(ReceivedShareAction(Left(failure))),
          (success) {
            if (success is DisableOfflineReceivedShareViewState && success.result == OfflineModeActionResult.successful) {
              store.dispatch(ReceivedShareAction(Right(success)));
            } else {
              store.dispatch(ReceivedShareAction(Left(CannotOfflineReceivedShare())));
            }
          }));
    };
  }

  void openSearchState(BuildContext context) {
    store.dispatch(EnableSearchStateAction(SearchDestination.receivedShares, AppLocalizations.of(context).search_in_my_received_shares));
    store.dispatch((ReceivedShareSetSearchResultAction([])));
  }

  void goToDetails(ReceivedShare receivedShare) {
    _appNavigation.popAndPush(RoutePaths.receivedShareDetails,
        arguments: ReceivedShareDetailsArguments(receivedShare));
  }

  @override
  void onDisposed() {
    cancelSelection();
    super.onDisposed();
    _storeStreamSubscription.cancel();
  }
}
