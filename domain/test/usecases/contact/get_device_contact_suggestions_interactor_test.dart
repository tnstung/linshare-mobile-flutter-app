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
// Linagora © 2009–2021. Contribute to Linshare R&D by subscribing to an Enterprise 
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

import 'package:domain/src/model/autocomplete/autocomplete_pattern.dart';
import 'package:domain/src/repository/contact/contact_repository.dart';
import 'package:domain/src/usecases/contact/get_device_contact_suggestions_interactor.dart';
import 'package:domain/src/usecases/contact/get_device_contact_suggestions_view_state.dart';
import 'package:test/test.dart';
import 'package:mockito/mockito.dart';
import 'package:testshared/testshared.dart';

import '../../mock/repository/mock_contact_repository.dart';

void main() {
  group('get_device_contact_suggestions_interactor_test', () {
    late ContactRepository contactRepository;
    late GetDeviceContactSuggestionsInteractor getDeviceContactSuggestionsInteractor;

    setUp(() {
      contactRepository = MockContactRepository();
      getDeviceContactSuggestionsInteractor = GetDeviceContactSuggestionsInteractor(contactRepository);
    });

    test('get device contact should return suggestions with valid data', () async {
      final pattern = AutoCompletePattern('test');
      when(contactRepository.getContactSuggestions(pattern))
        .thenAnswer((_) async => [contact1, contact2]);

      final state = await getDeviceContactSuggestionsInteractor.execute(pattern);
      state.fold(
        (failure) => null,
        (success) {
          expect(success, isA<GetDeviceContactSuggestionsViewState>());
          expect([contact1, contact2], (success as GetDeviceContactSuggestionsViewState).results);
        });
    });

    test('get device contact should throw exception', () async {
      final pattern = AutoCompletePattern('test');
      when(contactRepository.getContactSuggestions(pattern))
          .thenThrow(Exception());

      final state = await getDeviceContactSuggestionsInteractor.execute(pattern);
      state.fold(
              (failure) => expect(failure, isA<GetDeviceContactSuggestionsFailure>()),
              (success) => null);
    });
  });
}
