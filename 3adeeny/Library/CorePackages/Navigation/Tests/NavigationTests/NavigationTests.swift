import Testing
import Foundation
@testable import Navigation

// MARK: - NavIdExtractor

@Suite("NavIdExtractor")
struct NavIdExtractorTests {
    @Test func extractsBeforeParenthesis() {
        #expect("home(someValue)".extractedStringBeforeParenthesis() == "home")
    }

    @Test func returnsOriginalWhenNoParenthesis() {
        #expect("profile".extractedStringBeforeParenthesis() == "profile")
    }

    @Test func emptyStringReturnsEmpty() {
        #expect("".extractedStringBeforeParenthesis() == "")
    }

    @Test func usesFirstParenthesisOnly() {
        #expect("foo(bar)(baz)".extractedStringBeforeParenthesis() == "foo")
    }
}

// MARK: - Screen

@Suite("Screen")
struct ScreenTests {
    @Test func homeIDMatchesEnumCase() {
        #expect(Screen.home.id == "home")
    }

    @Test func profileIDMatchesEnumCase() {
        #expect(Screen.profile.id == "profile")
    }

    @Test func equalityBetweenSameCases() {
        #expect(Screen.home == Screen.home)
        #expect(Screen.profile == Screen.profile)
    }

    @Test func inequalityBetweenDifferentCases() {
        #expect(Screen.home != Screen.profile)
    }

    @Test func usableInSet() {
        var set: Set<Screen> = []
        set.insert(.home)
        set.insert(.home)
        #expect(set.count == 1)
        set.insert(.profile)
        #expect(set.count == 2)
    }
}

// MARK: - Sheet

@Suite("Sheet")
struct SheetTests {
    @Test func bottomSheetIDMatchesEnumCase() {
        #expect(Sheet.bottomSheet.id == "bottomSheet")
    }

    @Test func equalityBetweenSameCases() {
        #expect(Sheet.bottomSheet == Sheet.bottomSheet)
    }
}

// MARK: - FullScreenCover

@Suite("FullScreenCover")
struct FullScreenCoverTests {
    @Test func fullScreenViewIDMatchesEnumCase() {
        #expect(FullScreenCover.fullScreenView.id == "fullScreenView")
    }

    @Test func equalityBetweenSameCases() {
        #expect(FullScreenCover.fullScreenView == FullScreenCover.fullScreenView)
    }
}

// MARK: - Tab

@Suite("Tab")
struct TabTests {
    @Test func convertHomeFromLowercaseString() {
        #expect(Tab.convert(from: "home") == .home)
    }

    @Test func convertProfileFromLowercaseString() {
        #expect(Tab.convert(from: "profile") == .profile)
    }

    @Test func convertIsCaseInsensitive() {
        #expect(Tab.convert(from: "HOME") == .home)
        #expect(Tab.convert(from: "Profile") == .profile)
        #expect(Tab.convert(from: "PROFILE") == .profile)
    }

    @Test func convertInvalidStringReturnsNil() {
        #expect(Tab.convert(from: "unknown") == nil)
        #expect(Tab.convert(from: "") == nil)
    }

    @Test func rawValues() {
        #expect(Tab.home.rawValue == "home")
        #expect(Tab.profile.rawValue == "profile")
    }

    @Test func allCasesContainsBothTabs() {
        #expect(Tab.allCases.count == 2)
        #expect(Tab.allCases.contains(.home))
        #expect(Tab.allCases.contains(.profile))
    }
}

// MARK: - NavRouter

@Suite("NavRouter")
@MainActor
struct NavRouterTests {
    @Test func initialStateIsEmpty() {
        let router = NavRouter()
        #expect(router.path.isEmpty)
        #expect(router.sheet == nil)
        #expect(router.fullScreenCover == nil)
    }

    @Test func pushAppendsScreen() {
        let router = NavRouter()
        router.push(.home)
        #expect(router.path == [.home])
    }

    @Test func pushMultipleScreensMaintainsOrder() {
        let router = NavRouter()
        router.push(.home)
        router.push(.profile)
        #expect(router.path == [.home, .profile])
    }

    @Test func popRemovesLastScreen() {
        let router = NavRouter()
        router.push(.home)
        router.push(.profile)
        router.pop()
        #expect(router.path == [.home])
    }

    @Test func popOnEmptyPathDoesNothing() {
        let router = NavRouter()
        router.pop()
        #expect(router.path.isEmpty)
    }

    @Test func popToRootClearsAllScreens() {
        let router = NavRouter()
        router.push(.home)
        router.push(.profile)
        router.push(.home)
        router.popToRoot()
        #expect(router.path.isEmpty)
    }

    @Test func popToRootOnEmptyPathDoesNothing() {
        let router = NavRouter()
        router.popToRoot()
        #expect(router.path.isEmpty)
    }

    @Test func popCountRemovesExactNumberOfScreens() {
        let router = NavRouter()
        router.push(.home)
        router.push(.profile)
        router.push(.home)
        router.pop(count: 2)
        #expect(router.path == [.home])
    }

    @Test func popCountZeroDoesNothing() {
        let router = NavRouter()
        router.push(.home)
        router.pop(count: 0)
        #expect(router.path.count == 1)
    }

    @Test func popCountExceedingPathSizeDoesNothing() {
        let router = NavRouter()
        router.push(.home)
        router.pop(count: 5)
        #expect(router.path.count == 1)
    }

    @Test func popCountExactlyPathSizeClearsPath() {
        let router = NavRouter()
        router.push(.home)
        router.push(.profile)
        router.pop(count: 2)
        #expect(router.path.isEmpty)
    }

    @Test func popToScreenRemovesEverythingAfterIt() {
        let router = NavRouter()
        router.push(.home)
        router.push(.profile)
        router.push(.home)
        router.pop(to: .profile)
        #expect(router.path == [.home, .profile])
    }

    @Test func popToLastOccurrenceWhenDuplicates() {
        let router = NavRouter()
        router.push(.home)
        router.push(.profile)
        router.push(.home)
        router.push(.profile)
        router.pop(to: .profile)
        // lastIndex of .profile is index 3, nothing to remove after it
        #expect(router.path.count == 4)
    }

    @Test func popToScreenNotInPathDoesNothing() {
        let router = NavRouter()
        router.push(.home)
        router.push(.home)
        router.pop(to: .profile)
        #expect(router.path.count == 2)
    }

    @Test func presentSheetSetsSheet() {
        let router = NavRouter()
        router.present(sheet: .bottomSheet)
        #expect(router.sheet == .bottomSheet)
    }

    @Test func dismissSheetNilsSheet() {
        let router = NavRouter()
        router.present(sheet: .bottomSheet)
        router.dismissSheet()
        #expect(router.sheet == nil)
    }

    @Test func dismissSheetWhenNilDoesNothing() {
        let router = NavRouter()
        router.dismissSheet()
        #expect(router.sheet == nil)
    }

    @Test func presentFullScreenCoverSetsIt() {
        let router = NavRouter()
        router.present(fullScreenCover: .fullScreenView)
        #expect(router.fullScreenCover == .fullScreenView)
    }

    @Test func dismissFullScreenCoverNilsIt() {
        let router = NavRouter()
        router.present(fullScreenCover: .fullScreenView)
        router.dismissFullScreenCover()
        #expect(router.fullScreenCover == nil)
    }

    @Test func dismissFullScreenCoverWhenNilDoesNothing() {
        let router = NavRouter()
        router.dismissFullScreenCover()
        #expect(router.fullScreenCover == nil)
    }
}

// MARK: - AppState

@Suite("AppState")
@MainActor
struct AppStateTests {
    @Test func initialAppStateIsOnboarding() {
        let appState = AppState()
        #expect(appState.currentAppStateFlow == .onboarding)
    }

    @Test func initialSelectedTabIsHome() {
        let appState = AppState()
        #expect(appState.selectedTab == .home)
    }

    @Test func activeRouterForHomeTabReturnsHomeRouter() {
        let appState = AppState()
        appState.selectedTab = .home
        #expect(appState.activeRouter === appState.homeRouter)
    }

    @Test func activeRouterForProfileTabReturnsProfileRouter() {
        let appState = AppState()
        appState.selectedTab = .profile
        #expect(appState.activeRouter === appState.profileRouter)
    }

    @Test func changingAppStateFlowUpdatesRootViewID() {
        let appState = AppState()
        let initialID = appState.rootViewID
        appState.currentAppStateFlow = .loggedIn
        #expect(appState.rootViewID != initialID)
    }

    @Test func settingSameAppStateFlowAlsoUpdatesRootViewID() {
        let appState = AppState()
        appState.currentAppStateFlow = .loggedIn
        let idAfterFirst = appState.rootViewID
        appState.currentAppStateFlow = .loggedIn
        #expect(appState.rootViewID != idAfterFirst)
    }

    @Test func resetTabClearsHomeRouterPath() {
        let appState = AppState()
        appState.selectedTab = .home
        appState.homeRouter.push(.home)
        appState.homeRouter.push(.profile)
        appState.resetTab()
        #expect(appState.homeRouter.path.isEmpty)
    }

    @Test func resetTabClearsProfileRouterPath() {
        let appState = AppState()
        appState.selectedTab = .profile
        appState.profileRouter.push(.home)
        appState.profileRouter.push(.profile)
        appState.resetTab()
        #expect(appState.profileRouter.path.isEmpty)
    }

    @Test func resetTabDoesNotAffectOtherRouter() {
        let appState = AppState()
        appState.selectedTab = .home
        appState.homeRouter.push(.home)
        appState.profileRouter.push(.profile)
        appState.resetTab()
        #expect(appState.homeRouter.path.isEmpty)
        #expect(appState.profileRouter.path.count == 1)
    }

    @Test func tappingSameTabResetsNavigation() {
        let appState = AppState()
        appState.selectedTab = .home
        appState.homeRouter.push(.home)
        appState.homeRouter.push(.profile)
        // willSet fires when same tab is selected — calls resetTab()
        appState.selectedTab = .home
        #expect(appState.homeRouter.path.isEmpty)
    }

    @Test func switchingToNewTabDoesNotResetRouters() {
        let appState = AppState()
        appState.selectedTab = .home
        appState.homeRouter.push(.home)
        // Switching to a different tab should not reset
        appState.selectedTab = .profile
        #expect(appState.homeRouter.path.count == 1)
    }
}
