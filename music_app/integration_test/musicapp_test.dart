import 'package:music_app/domin/entities/artist.dart';
import 'package:music_app/domin/usecases/artists/search_for_artist.dart';
import 'package:music_app/presentation/blocs/artists/bloc/artists_bloc.dart';
import 'package:music_app/presentation/blocs/favorite_albums/bloc/favorite_albums_bloc.dart';
import 'package:music_app/presentation/pages/search_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:music_app/main.dart' as app;
import 'package:integration_test/integration_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart'; // Import the GetIt packa

class MockSearchForArtist extends Mock implements SearchForArtist {}

// Setup mocks for Artists
class MockArtistsBloc extends Mock implements ArtistsBloc {}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final getIt = GetIt.instance;

  // Create mock instance
  late MockFavoriteAlbumsBloc mockFavoriteAlbumsBloc;
  late MockArtistsBloc mockArtistBloc;
  late MockSearchForArtist mockSearchForArtist;

  setUp(() {
    // Clear GetIt to avoid conflicts with previous registrations
    getIt.reset();

    mockFavoriteAlbumsBloc = MockFavoriteAlbumsBloc();
    mockArtistBloc = MockArtistsBloc();
    mockSearchForArtist = MockSearchForArtist();

    // Register all necessary dependencies
    getIt.registerSingleton<FavoriteAlbumsBloc>(mockFavoriteAlbumsBloc);
    getIt.registerSingleton<SearchForArtist>(mockSearchForArtist);
    getIt.registerSingleton<ArtistsBloc>(mockArtistBloc);

  // Need help : 
  // We tried to mock the Artist bloc but it failed due to nullity. We need help to understand how to mock this bloc and register in GetIt
    
    //when(mockArtistBloc.state).thenReturn(ArtistsInitial());
/*
    when(mockArtistBloc.stream).thenAnswer((_) => Stream.fromIterable([
          ArtistSearchLoadingState(),
          ArtistSearchSucccssState(
              mockArtistData()), // Mock the success data here
        ]));
*/
  });

  tearDown(() {
    getIt.reset();
  });

  testWidgets("Music App Integration Test", (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();
    expect(find.text('Music App'), findsOneWidget);

    await Future.delayed(const Duration(seconds: 1));

    await tester.tap(find.byIcon(Icons.search));
    await tester.pumpAndSettle();

    var artist = "Linkin Park";
    await tester.enterText(find.byType(TextField), artist);
    await Future.delayed(const Duration(seconds: 1));
    mockArtistBloc.addSearchForArtist(artist);
    await tester.tap(find.byIcon(Icons.search));
    await tester.pumpAndSettle();

    // Verify that search results for the artist is displayed.
    await Future.delayed(const Duration(seconds: 2));
    expect(find.byType(GridView), findsAtLeast(1));
    expect(find.byType(ArtistWidget), findsAtLeast(2));


  });
}

class MockFavoriteAlbumsBloc extends Mock implements FavoriteAlbumsBloc {}

List<Artist> mockArtistData() {
  return [
    TestArtist(name: 'Linkin Park'),
    TestArtist(name: 'Chester Bennington'),
  ];
}

class TestArtist extends Artist {
  TestArtist({
    String? name,
    String? listeners,
    String? mbid,
    String? url,
    String? streamable,
  }) {
    this.name = name;
    this.listeners = listeners;
    this.mbid = mbid;
    this.url = url;
    this.streamable = streamable;
  }
}
