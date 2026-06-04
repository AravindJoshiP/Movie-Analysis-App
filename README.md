# Movie Browser App using TMDB — UIKit + Storyboard

This package contains a complete UIKit implementation for your CSC 491 final project proposal.

Based on your proposal, the app includes:
- Popular movies
- Now playing / theatre movies
- Search movies
- Movie details
- Cast list
- Similar / recommended movies
- Favorites saved locally using Core Data
- Settings / About screen

## Important setup

1. Create a new Xcode project:
   - iOS App
   - Interface: Storyboard
   - Language: Swift
   - Product name: `MovieBrowser`

2. Copy all Swift files from this package into your Xcode project.

3. Add your TMDB API key:
   Open `TMDBConfig.swift` and replace:
   ```swift
   static let apiKey = "PUT_YOUR_TMDB_API_KEY_HERE"
   ```

4. Storyboard structure:
   - Add a `UITabBarController` and set it as Initial View Controller.
   - Add 5 Navigation Controllers connected to the Tab Bar Controller.
   - Each Navigation Controller root should be:
     1. `MoviesGridViewController` for Popular
     2. `MoviesGridViewController` for Now Playing
     3. `SearchViewController`
     4. `FavoritesViewController`
     5. `SettingsViewController`

5. In Storyboard, set the custom class of each root controller:
   - Popular screen: `MoviesGridViewController`
   - Now Playing screen: `MoviesGridViewController`
   - Search screen: `SearchViewController`
   - Favorites screen: `FavoritesViewController`
   - Settings screen: `SettingsViewController`

6. For Popular and Now Playing screens:
   In `viewDidLoad`, this project automatically detects tab index:
   - tab index 0 = popular movies
   - tab index 1 = now playing movies

7. Add App Transport Security only if needed. TMDB image/API URLs use HTTPS, so usually no change is required.

## Storyboard design recommendation

Keep each view controller empty in Storyboard except for the controller itself. The UI is created in code using UIKit, but the navigation/tab structure is still storyboard-based. This avoids outlet errors and makes your project easier to run.

## Files included

- `Movie.swift` — movie model
- `CastMember.swift` — cast model
- `TMDBService.swift` — API requests
- `ImageLoader.swift` — poster image loading/cache
- `CoreDataManager.swift` — local favorites persistence
- `MovieCell.swift` — Netflix-style movie grid cell
- `CastCell.swift` — cast list cell
- `MoviesGridViewController.swift` — popular/now playing/recommendations screen
- `MovieDetailViewController.swift` — description screen
- `SearchViewController.swift` — search screen
- `FavoritesViewController.swift` — saved movies screen
- `CastViewController.swift` — cast screen
- `SettingsViewController.swift` — settings/about screen
- `SceneDelegate.swift` — optional styling for tabs/navigation
