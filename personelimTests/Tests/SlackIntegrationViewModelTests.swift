//
//  SlackIntegrationViewModelTests.swift
//  personelim
//
//  Created by Yusuf Kaan USTA on 12.06.2026.
//

import XCTest
@testable import personelim

@MainActor
final class SlackIntegrationViewModelTests: XCTestCase {

    private var repository: MockSlackWebhookRepository!
    private var vm: SlackIntegrationViewModel!

    override func setUp() {
        super.setUp()

        repository = MockSlackWebhookRepository()
        vm = SlackIntegrationViewModel(repository: repository)
    }

    override func tearDown() {
        vm = nil
        repository = nil
        super.tearDown()
    }

    func testLoadSuccessSetsIntegrations() async {
        repository.integrationsResult = .success([
            makeIntegration(id: "slack-1", label: "Genel")
        ])

        await vm.load(businessId: "business-1")

        XCTAssertFalse(vm.isLoading)
        XCTAssertNil(vm.errorMessage)
        XCTAssertEqual(vm.integrations.count, 1)
        XCTAssertEqual(vm.integrations.first?.label, "Genel")
        XCTAssertEqual(repository.getIntegrationsCallCount, 1)
        XCTAssertEqual(repository.receivedBusinessId, "business-1")
    }

    func testLoadFailureSetsErrorMessage() async {
        repository.integrationsResult = .failure(SlackIntegrationViewModelTestError.sample)

        await vm.load(businessId: "business-1")

        XCTAssertFalse(vm.isLoading)
        XCTAssertEqual(vm.errorMessage, SlackIntegrationViewModelTestError.sample.localizedDescription)
        XCTAssertTrue(vm.integrations.isEmpty)
    }

    func testCreateWhenLabelEmptyReturnsFalseAndSetsError() async {
        let result = await vm.create(
            businessId: "business-1",
            label: "   ",
            webhookUrl: "https://hooks.slack.com/test",
            eventTypes: [.task]
        )

        XCTAssertFalse(result)
        XCTAssertEqual(vm.errorMessage, ConstantStrings.slackChannelNameRequired)
        XCTAssertEqual(repository.createIntegrationCallCount, 0)
    }

    func testCreateWhenWebhookUrlEmptyReturnsFalseAndSetsError() async {
        let result = await vm.create(
            businessId: "business-1",
            label: "Genel",
            webhookUrl: "   ",
            eventTypes: [.task]
        )

        XCTAssertFalse(result)
        XCTAssertEqual(vm.errorMessage, ConstantStrings.slackWebhookURLRequired)
        XCTAssertEqual(repository.createIntegrationCallCount, 0)
    }

    func testCreateWhenEventTypesEmptyReturnsFalseAndSetsError() async {
        let result = await vm.create(
            businessId: "business-1",
            label: "Genel",
            webhookUrl: "https://hooks.slack.com/test",
            eventTypes: []
        )

        XCTAssertFalse(result)
        XCTAssertEqual(vm.errorMessage, ConstantStrings.slackActivityTypeRequired)
        XCTAssertEqual(repository.createIntegrationCallCount, 0)
    }

    func testCreateSuccessTrimsValuesAndReloadsIntegrations() async {
        repository.createResult = .success(())
        repository.integrationsResult = .success([
            makeIntegration(id: "slack-1", label: "Genel")
        ])

        let result = await vm.create(
            businessId: "business-1",
            label: "  Genel  ",
            webhookUrl: "  https://hooks.slack.com/test  ",
            eventTypes: [.task, .meeting]
        )

        XCTAssertTrue(result)
        XCTAssertFalse(vm.isLoading)
        XCTAssertNil(vm.errorMessage)

        XCTAssertEqual(repository.createIntegrationCallCount, 1)
        XCTAssertEqual(repository.receivedCreateBusinessId, "business-1")
        XCTAssertEqual(repository.receivedCreateLabel, "Genel")
        XCTAssertEqual(repository.receivedCreateWebhookUrl, "https://hooks.slack.com/test")
        XCTAssertEqual(repository.receivedCreateEventTypes, [.task, .meeting])

        XCTAssertEqual(repository.getIntegrationsCallCount, 1)
        XCTAssertEqual(vm.integrations.count, 1)
    }

    func testCreateFailureSetsErrorMessage() async {
        repository.createResult = .failure(SlackIntegrationViewModelTestError.sample)

        let result = await vm.create(
            businessId: "business-1",
            label: "Genel",
            webhookUrl: "https://hooks.slack.com/test",
            eventTypes: [.task]
        )

        XCTAssertFalse(result)
        XCTAssertFalse(vm.isLoading)
        XCTAssertEqual(vm.errorMessage, SlackIntegrationViewModelTestError.sample.localizedDescription)
        XCTAssertEqual(repository.createIntegrationCallCount, 1)
        XCTAssertEqual(repository.getIntegrationsCallCount, 0)
    }

    func testUpdateSuccessTrimsValuesAndReloadsIntegrations() async {
        let integration = makeIntegration(id: "slack-1", label: "Eski")

        repository.updateResult = .success(())
        repository.integrationsResult = .success([
            makeIntegration(id: "slack-1", label: "Yeni")
        ])

        let result = await vm.update(
            integration: integration,
            businessId: "business-1",
            label: "  Yeni  ",
            webhookUrl: "  https://hooks.slack.com/new  ",
            eventTypes: [.event]
        )

        XCTAssertTrue(result)
        XCTAssertFalse(vm.isLoading)
        XCTAssertNil(vm.errorMessage)

        XCTAssertEqual(repository.updateIntegrationCallCount, 1)
        XCTAssertEqual(repository.receivedUpdateIntegration?.id, "slack-1")
        XCTAssertEqual(repository.receivedUpdateBusinessId, "business-1")
        XCTAssertEqual(repository.receivedUpdateLabel, "Yeni")
        XCTAssertEqual(repository.receivedUpdateWebhookUrl, "https://hooks.slack.com/new")
        XCTAssertEqual(repository.receivedUpdateEventTypes, [.event])

        XCTAssertEqual(repository.getIntegrationsCallCount, 1)
        XCTAssertEqual(vm.integrations.first?.label, "Yeni")
    }

    func testUpdateFailureSetsErrorMessage() async {
        let integration = makeIntegration(id: "slack-1", label: "Genel")
        repository.updateResult = .failure(SlackIntegrationViewModelTestError.sample)

        let result = await vm.update(
            integration: integration,
            businessId: "business-1",
            label: "Genel",
            webhookUrl: "https://hooks.slack.com/test",
            eventTypes: [.task]
        )

        XCTAssertFalse(result)
        XCTAssertFalse(vm.isLoading)
        XCTAssertEqual(vm.errorMessage, SlackIntegrationViewModelTestError.sample.localizedDescription)
        XCTAssertEqual(repository.updateIntegrationCallCount, 1)
        XCTAssertEqual(repository.getIntegrationsCallCount, 0)
    }

    private func makeIntegration(
        id: String = "slack-1",
        label: String = "Genel",
        webhookUrl: String = "https://hooks.slack.com/test",
        eventTypes: [SlackActivityType] = [.task]
    ) -> SlackIntegration {
        SlackIntegration(
            id: id,
            label: label,
            webhookUrl: webhookUrl,
            eventTypes: eventTypes,
            records: eventTypes.enumerated().map { index, type in
                SlackWebhookRecord(
                    id: "\(id)-record-\(index)",
                    activityType: type
                )
            }
        )
    }
}

private enum SlackIntegrationViewModelTestError: LocalizedError {
    case sample

    var errorDescription: String? {
        "Test hatası"
    }
}
