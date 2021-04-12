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

import 'package:dartz/dartz.dart';
import 'package:domain/domain.dart';
import 'package:domain/src/state/failure.dart';
import 'package:domain/src/state/success.dart';
import 'package:flutter/foundation.dart';
import 'package:linshare_flutter_app/presentation/model/file/selectable_element.dart';
import 'package:linshare_flutter_app/presentation/redux/states/linshare_state.dart';
import 'package:equatable/equatable.dart';
import 'package:linshare_flutter_app/presentation/widget/shared_space_document/shared_space_document_arguments.dart';
import 'package:linshare_flutter_app/presentation/widget/shared_space_document/shared_space_document_type.dart';

@immutable
class SharedSpaceDocumentState extends LinShareState with EquatableMixin {
  final List<SelectableElement<WorkGroupNode>> workGroupNodeList;
  final SharedSpaceNodeNested sharedSpaceNodeNested;
  final SharedSpaceDocumentType documentType;
  final WorkGroupNode workGroupNode;
  final SelectMode selectMode;
  final Sorter sorter;

  SharedSpaceDocumentState(
    Either<Failure, Success> viewState,
    this.workGroupNodeList,
    this.documentType,
    this.workGroupNode,
    this.sharedSpaceNodeNested,
    this.selectMode,
    this.sorter
  ) : super(viewState);

  factory SharedSpaceDocumentState.initial() {
    return SharedSpaceDocumentState(Right(IdleState()), [], SharedSpaceDocumentType.root, null, null, SelectMode.INACTIVE, null);
  }

  @override
  SharedSpaceDocumentState clearViewState() {
    return SharedSpaceDocumentState(Right(IdleState()), workGroupNodeList, documentType, workGroupNode, sharedSpaceNodeNested, selectMode, sorter);
  }

  @override
  SharedSpaceDocumentState sendViewState({Either<Failure, Success> viewState}) {
    return SharedSpaceDocumentState(viewState, workGroupNodeList, documentType, workGroupNode, sharedSpaceNodeNested, selectMode, sorter);
  }

  SharedSpaceDocumentState setSharedSpaceDocumentArgument({SharedSpaceDocumentArguments newArguments}) {
    return SharedSpaceDocumentState(
      viewState,
      workGroupNodeList,
      newArguments.documentType ?? documentType,
      newArguments.workGroupFolder ?? workGroupNode,
      newArguments.sharedSpaceNode ?? sharedSpaceNodeNested,
      selectMode,
      sorter
    );
  }

  SharedSpaceDocumentState setSharedSpaceDocument({Either<Failure, Success> viewState, List<WorkGroupNode> newWorkGroupNodeList, Sorter newSorter}) {
    final selectedElements = workGroupNodeList.where((element) => element.selectMode == SelectMode.ACTIVE).map((element) => element.element).toList();

    return SharedSpaceDocumentState(
      viewState ?? this.viewState,
      newWorkGroupNodeList
          .map((workGroup) => selectedElements.contains(workGroup)
            ? SelectableElement<WorkGroupNode>(workGroup, SelectMode.ACTIVE)
            : SelectableElement<WorkGroupNode>(workGroup, SelectMode.INACTIVE))
          .toList(),
      documentType,
      workGroupNode,
      sharedSpaceNodeNested,
      selectMode,
      newSorter ?? sorter
    );
  }

  @override
  SharedSpaceDocumentState startLoadingState() {
    return SharedSpaceDocumentState(Right(LoadingState()), workGroupNodeList, documentType, workGroupNode, sharedSpaceNodeNested, selectMode, sorter);
  }

  LinShareState selectSharedSpaceDocument(SelectableElement<WorkGroupNode> selectedWokGroupNode) {
    workGroupNodeList.firstWhere((sharedSpace) => sharedSpace == selectedWokGroupNode).toggleSelect();
    return SharedSpaceDocumentState(viewState, workGroupNodeList, documentType, workGroupNode, sharedSpaceNodeNested, SelectMode.ACTIVE, sorter);
  }

  LinShareState cancelSelectedSharedSpaceDocument() {
    return SharedSpaceDocumentState(
      viewState,
      workGroupNodeList
          .map((workGroupNode) => SelectableElement<WorkGroupNode>(workGroupNode.element, SelectMode.INACTIVE))
          .toList(),
      documentType,
      workGroupNode,
      sharedSpaceNodeNested,
      SelectMode.INACTIVE,
      sorter
    );
  }

  LinShareState selectAllSharedSpaceDocument() {
    return SharedSpaceDocumentState(
      viewState,
      workGroupNodeList
          .map((workGroupNode) => SelectableElement<WorkGroupNode>(workGroupNode.element, SelectMode.ACTIVE))
          .toList(),
      documentType,
      workGroupNode,
      sharedSpaceNodeNested,
      SelectMode.ACTIVE,
      sorter
    );
  }

  LinShareState unSelectAllSharedSpaceDocument() {
    return SharedSpaceDocumentState(
      viewState,
      workGroupNodeList
          .map((workGroupNode) => SelectableElement<WorkGroupNode>(workGroupNode.element, SelectMode.INACTIVE))
          .toList(),
      documentType,
      workGroupNode,
      sharedSpaceNodeNested,
      SelectMode.ACTIVE,
      sorter
    );
  }


  @override
  List<Object> get props => [
    ...super.props,
    workGroupNodeList,
    documentType,
    workGroupNode,
    sharedSpaceNodeNested,
    sorter
  ];
}

extension MultipleSelections on SharedSpaceDocumentState {
  bool isAllSharedSpaceDocumentSelected() {
    return workGroupNodeList.every((workGroupNode) => workGroupNode.selectMode == SelectMode.ACTIVE);
  }

  List<WorkGroupNode> getAllSelectedSharedSpaceDocument() {
    return workGroupNodeList.where((workGroupNode) => workGroupNode.selectMode == SelectMode.ACTIVE).map((workGroupNode) => workGroupNode.element).toList();
  }
}