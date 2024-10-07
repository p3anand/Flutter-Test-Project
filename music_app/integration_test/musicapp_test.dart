import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:music_app/main.dart' as app;
import 'package:music_app/domin/entities/artist.dart';
import 'package:music_app/domin/entities/album.dart';
import 'package:music_app/presentation/blocs/favorite_albums/bloc/favorite_albums_bloc.dart';
import 'package:music_app/presentation/blocs/artists/bloc/artists_bloc.dart';
import 'package:mockito/mockito.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Mock classes
class MockFavoriteAlbumsBloc extends Mock implements FavoriteAlbumsBloc {}
class MockArtistsBloc extends Mock implements ArtistsBloc {}

// Concrete implementation of Artist for testing
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

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final getIt = GetIt.instance;

  late MockFavoriteAlbumsBloc mockFavoriteAlbumsBloc;
  late MockArtistsBloc mockArtistsBloc;

  setUp(() {
    getIt.reset();

    mockFavoriteAlbumsBloc = MockFavoriteAlbumsBloc();
    mockArtistsBloc = MockArtistsBloc();

    getIt.registerSingleton<FavoriteAlbumsBloc>(mockFavoriteAlbumsBloc);
    getIt.registerSingleton<ArtistsBloc>(mockArtistsBloc);
  });

  tearDown(() {
    getIt.reset();
  });

  testWidgets("Music App Integration Test", (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();
    expect(find.text('Music App'), findsOneWidget);
    debugPrint("App started successfully");

    // Tap search icon
    final searchIcon = find.byIcon(Icons.search);
    expect(searchIcon, findsOneWidget);
    await tester.tap(searchIcon);
    await tester.pumpAndSettle();
    debugPrint("Tapped search icon");

    // Enter search query
    var artist = "Michael Jackson";
    await tester.enterText(find.byType(TextField), artist);
    await tester.pumpAndSettle();
    debugPrint("Entered search query: $artist");

    // Trigger search
    final searchButton = find.byIcon(Icons.search).last;
    expect(searchButton, findsOneWidget);
    await tester.tap(searchButton);
    await tester.pumpAndSettle();
    debugPrint("Triggered search");

    // Debug: Print all text found on screen
    find.byType(Text).evaluate().forEach((element) {
      final widget = element.widget as Text;
      debugPrint("Found text: ${widget.data}");
    });

    // Verify search results
    final searchResults = find.byWidgetPredicate((widget) =>
    widget is ListTile || widget is Card || widget is InkWell,
        description: 'Search result item');
    expect(searchResults, findsAtLeastNWidgets(1), reason: 'No search results found');
    debugPrint("Found ${searchResults.evaluate().length} search results");

    // Tap on the first search result
    await tester.tap(searchResults.first);
    await tester.pumpAndSettle();
    debugPrint("Tapped on first search result");

    // Verify that the album details page is loaded
    expect(find.byType(Card), findsAtLeastNWidgets(1));
    debugPrint("Album details page loaded");

    // Find all album cards
    final albumCards = find.byType(Card);
    debugPrint("Number of album cards found: ${albumCards.evaluate().length}");

    // Mark the first two albums as favorites
    for (int i = 0; i < 2 && i < albumCards.evaluate().length; i++) {
      final card = albumCards.at(i);
      debugPrint("Analyzing card ${i + 1}:");

      final favoriteButton = find.descendant(
        of: card,
        matching: find.byIcon(Icons.favorite_border),
      );

      if (favoriteButton.evaluate().isNotEmpty) {
        await tester.tap(favoriteButton);
        await tester.pumpAndSettle();
        debugPrint("Tapped favorite button on album ${i + 1}");
      } else {
        debugPrint("No favorite button found on album ${i + 1}");
      }
    }

    // Navigate back to the search page
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    debugPrint("Navigated back to search page");

    // Navigate back to the home page
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    debugPrint("Navigated back to home page");

    // Verify that we're back on the home page
    expect(find.text('Music App'), findsOneWidget);
    debugPrint("Verified home page");

    // Check for favorited albums on the home page
    final favoritedAlbums = find.byType(Card);
    debugPrint("Number of favorited albums on home page: ${favoritedAlbums.evaluate().length}");

    // Verify that we have at least two favorited albums
    expect(favoritedAlbums, findsAtLeastNWidgets(2));

    debugPrint("Test completed successfully");
  });
}

List<Artist> mockArtistData() {
  return [
    TestArtist(
      name: 'Michael Jackson',
      listeners: '1000000',
      mbid: 'some_mbid_1',
      url: 'http://example.com/mj',
      streamable: 'yes',
    ),
    TestArtist(
      name: 'Janet Jackson',
      listeners: '500000',
      mbid: 'some_mbid_2',
      url: 'http://example.com/jj',
      streamable: 'yes',
    ),
  ];
}