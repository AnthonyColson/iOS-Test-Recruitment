//
//  RouterTests.swift
//  TheGoodCornerTests
//
//  Created by ANTHONY GIUNTA on 22/05/2026.
//

import Testing
import SwiftUI
@testable import TheGoodCorner

@Suite("RouterTests")
struct RouterTests {

    // MARK: - Test fixtures

    private enum TestRoute: Route {
        case first
        case second
        case third(id: Int)

        @ViewBuilder
        var view: some View {
            switch self {
            case .first: Text("first")
            case .second: Text("second")
            case .third(let id): Text("third \(id)")
            }
        }
    }

    // MARK: - Initial state

    @Test func initialStateIsEmpty() {
        let sut = Router<TestRoute>()
        #expect(sut.path.isEmpty)
        #expect(sut.sheet == nil)
        #expect(sut.fullCover == nil)
    }

    // MARK: - navigate(to:mode:)

    @Test(arguments: [NavigationMode.push, .sheet, .fullCover])
    func navigateTargetsTheCorrectStateForMode(mode: NavigationMode) {
        let sut = Router<TestRoute>()

        sut.navigate(to: .first, mode: mode)

        switch mode {
        case .push:
            #expect(sut.path.count == 1)
            #expect(sut.sheet == nil)
            #expect(sut.fullCover == nil)
        case .sheet:
            #expect(sut.path.isEmpty)
            #expect(sut.sheet == .first)
            #expect(sut.fullCover == nil)
        case .fullCover:
            #expect(sut.path.isEmpty)
            #expect(sut.sheet == nil)
            #expect(sut.fullCover == .first)
        }
    }

    @Test func navigatePushAppendsMultipleRoutes() {
        let sut = Router<TestRoute>()
        sut.navigate(to: .first)
        sut.navigate(to: .second)
        sut.navigate(to: .third(id: 42))
        #expect(sut.path.count == 3)
    }

    // MARK: - Pop

    @Test func popRemovesLastEntry() {
        let sut = Router<TestRoute>()
        sut.navigate(to: .first)
        sut.navigate(to: .second)

        sut.pop()

        #expect(sut.path.count == 1)
    }

    @Test func popOnEmptyPathIsNoOp() {
        let sut = Router<TestRoute>()
        sut.pop()
        #expect(sut.path.isEmpty)
    }

    @Test func popToRootClearsEntirePath() {
        let sut = Router<TestRoute>()
        sut.navigate(to: .first)
        sut.navigate(to: .second)
        sut.navigate(to: .third(id: 3))

        sut.popToRoot()

        #expect(sut.path.isEmpty)
    }

    // MARK: - Dismiss

    @Test func dismissSheetClearsOnlyTheSheet() {
        let sut = Router<TestRoute>()
        sut.navigate(to: .first, mode: .sheet)
        sut.navigate(to: .second, mode: .fullCover)

        sut.dismissSheet()

        #expect(sut.sheet == nil)
        #expect(sut.fullCover == .second)
    }

    @Test func dismissFullCoverClearsOnlyTheFullCover() {
        let sut = Router<TestRoute>()
        sut.navigate(to: .first, mode: .sheet)
        sut.navigate(to: .second, mode: .fullCover)

        sut.dismissFullCover()

        #expect(sut.fullCover == nil)
        #expect(sut.sheet == .first)
    }

    @Test func dismissClearsBothModalsButKeepsPath() {
        let sut = Router<TestRoute>()
        sut.navigate(to: .first)
        sut.navigate(to: .second, mode: .sheet)
        sut.navigate(to: .third(id: 3), mode: .fullCover)

        sut.dismiss()

        #expect(sut.sheet == nil)
        #expect(sut.fullCover == nil)
        #expect(sut.path.count == 1)
    }

    // MARK: - Reset

    @Test func resetClearsPathAndBothModals() {
        let sut = Router<TestRoute>()
        sut.navigate(to: .first)
        sut.navigate(to: .second, mode: .sheet)
        sut.navigate(to: .third(id: 3), mode: .fullCover)

        sut.reset()

        #expect(sut.path.isEmpty)
        #expect(sut.sheet == nil)
        #expect(sut.fullCover == nil)
    }
}
