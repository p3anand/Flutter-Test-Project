import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:music_app/main.dart' as app;
import 'package:favorite_button/favorite_button.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets("Music App Integration Test", (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();
    expect(find.text('Music App'), findsOneWidget);
    debugPrint("App started successfully");

    // Click on search icon
    final searchIcon = find.byIcon(Icons.search);
    expect(searchIcon, findsOneWidget);
    await tester.tap(searchIcon);
    await tester.pumpAndSettle();
    debugPrint("Tapped search icon");

    // Enter search text
    var artist = "Eminem";
    await tester.enterText(find.byType(TextField), artist);
    await tester.pumpAndSettle();
    debugPrint("Entered search query: $artist");

    // Start Search
    final searchButton = find.byIcon(Icons.search).last;
    expect(searchButton, findsOneWidget);
    await tester.tap(searchButton);
    await tester.pumpAndSettle(const Duration(seconds: 5));
    debugPrint("Triggered search");

    // Print all text on the screen
    debugPrint("Text found on screen:");
    tester.widgetList(find.byType(Text)).forEach((widget) {
      if (widget is Text) {
        debugPrint(widget.data);
      }
    });

    // Verify search results
    expect(find.text(artist), findsAtLeastNWidgets(1), reason: 'No search results found for $artist');
    debugPrint("Found search results for $artist");

    // Tap on the first search result
    await tester.tap(find.text(artist).first);
    await tester.pumpAndSettle(const Duration(seconds: 5));
    debugPrint("Tapped on first search result");

    // Verify that the album details page is loaded
    expect(find.byType(Card), findsAtLeastNWidgets(1));
    debugPrint("Album details page loaded");

    // Find all album cards
    final albumCards = find.byType(Card);
    debugPrint("Number of album cards found: ${albumCards.evaluate().length}");

    // Selecting two albums as favorite albums
    int favoritedCount = 0;
    for (int i = 0; i < albumCards.evaluate().length && favoritedCount < 2; i++) {
      final card = albumCards.at(i);
      debugPrint("Analyzing card ${i + 1}:");

      // Print all widgets in the card
      final widgets = find.descendant(of: card, matching: find.byWidgetPredicate((_) => true));
      //debugPrint("Widgets found in card ${i + 1}:");
      widgets.evaluate().forEach((element) {
        //debugPrint(element.widget.runtimeType.toString());
      });

      // Try to find and tap the favorite button
      final favoriteButton = find.descendant(
        of: card,
        matching: find.byType(FavoriteButton),
      );

      if (favoriteButton.evaluate().isNotEmpty) {
        await tester.tap(favoriteButton);
        await tester.pumpAndSettle(const Duration(seconds: 5));
        debugPrint("Tapped favorite button on album ${i + 1}");

        // Check for error message
        final errorMessage = find.text('Sorry! we are unable to save your album');
        await tester.pump(const Duration(seconds: 2)); // Wait for error message to appear

        if (errorMessage.evaluate().isNotEmpty) {
          debugPrint("NOTE - ERROR MESSAGE FOUND: ${(tester.widget(errorMessage) as Text).data}");
        } else {
          favoritedCount++;
          debugPrint("Album ${i + 1} favorited successfully");
        }
      } else {
        debugPrint("No favorite button found on album ${i + 1}");
      }
    }

    // Verify that at least one album was marked favorite successfully
    expect(favoritedCount, greaterThan(0), reason: 'No albums were marked favourite');

    // Navigate back to the home page
    while (find.byType(BackButton).evaluate().isNotEmpty) {
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle(const Duration(seconds: 8));
      debugPrint("Navigated back");
    }

    // Verify that we're back on the home page
    expect(find.text('Music App'), findsOneWidget);
    debugPrint("Verified home page");

    // Check for favorite albums on the home page
    final favoritedAlbums = find.byType(Card);
    debugPrint("Number of favorited albums on home page: ${favoritedAlbums.evaluate().length}");

    // Print all text on the home page
    debugPrint("Text found on home page:");
    tester.widgetList(find.byType(Text)).forEach((widget) {
      if (widget is Text) {
        debugPrint(widget.data);
      }
    });

    // Verify that we have at least one favorite album
    expect(favoritedAlbums, findsAtLeastNWidgets(1), reason: 'Expected at least 1 album to be marked favorite, but found ${favoritedAlbums.evaluate().length}');

    // Test navigation to album details from favorited album
    if (favoritedAlbums.evaluate().isNotEmpty) {
      // Tap on the first favorited album
      await tester.tap(favoritedAlbums.first);
      await tester.pumpAndSettle(const Duration(seconds: 5));
      debugPrint("Tapped on favorited album");

      // Verify that we're on the album details page
      //expect(find.byType(Card), findsAtLeastNWidgets(1));
      //expect(find.text('Tracks'), findsOneWidget);
      debugPrint("Navigated to album details page");
      await tester.pump(const Duration(seconds: 2));


      // Navigate back to the home page
      final backButton = find.byType(BackButton);
      expect(backButton, findsOneWidget);
      await tester.tap(backButton);
      await tester.pumpAndSettle(const Duration(seconds: 5));
      debugPrint("Navigated back to home page");

      // Verify that we're back on the home page
      expect(find.text('Music App'), findsOneWidget);
      debugPrint("Verified return to home page after viewing album details");
    } else {
      debugPrint("We are lost");
    }

    debugPrint("Test End");
  });
}