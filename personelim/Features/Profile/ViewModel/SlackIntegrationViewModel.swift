import Foundation

@MainActor
final class SlackIntegrationViewModel: ObservableObject {

    @Published var integrations: [SlackIntegration] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let getIntegrationsUseCase: GetSlackIntegrationsUseCase
    private let createIntegrationUseCase: CreateSlackIntegrationUseCase
    private let updateIntegrationUseCase: UpdateSlackIntegrationUseCase

    init(repository: SlackWebhookRepositoryProtocol = SlackWebhookRepositoryImpl()) {
        getIntegrationsUseCase = GetSlackIntegrationsUseCase(repository: repository)
        createIntegrationUseCase = CreateSlackIntegrationUseCase(repository: repository)
        updateIntegrationUseCase = UpdateSlackIntegrationUseCase(repository: repository)
    }

    func load(businessId: String) async {
        isLoading = true
        errorMessage = nil

        defer {
            isLoading = false
        }

        do {
            integrations = try await getIntegrationsUseCase.execute(
                businessId: businessId
            )
        } catch {
            errorMessage = userMessage(
                from: error,
                fallback: ConstantStrings.slackIntegrationLoadFailed
            )
        }
    }

    func create(
        businessId: String,
        label: String,
        webhookUrl: String,
        eventTypes: [SlackActivityType]
    ) async -> Bool {
        guard validate(
            label: label,
            webhookUrl: webhookUrl,
            eventTypes: eventTypes
        ) else {
            return false
        }

        isLoading = true
        errorMessage = nil

        defer {
            isLoading = false
        }

        do {
            try await createIntegrationUseCase.execute(
                businessId: businessId,
                label: trimmed(label),
                webhookUrl: trimmed(webhookUrl),
                eventTypes: eventTypes
            )

            await load(businessId: businessId)
            return true

        } catch {
            errorMessage = userMessage(
                from: error,
                fallback: ConstantStrings.slackIntegrationCreateFailed
            )
            return false
        }
    }

    func update(
        integration: SlackIntegration,
        businessId: String,
        label: String,
        webhookUrl: String,
        eventTypes: [SlackActivityType]
    ) async -> Bool {
        guard validate(
            label: label,
            webhookUrl: webhookUrl,
            eventTypes: eventTypes
        ) else {
            return false
        }

        isLoading = true
        errorMessage = nil

        defer {
            isLoading = false
        }

        do {
            try await updateIntegrationUseCase.execute(
                integration: integration,
                businessId: businessId,
                label: trimmed(label),
                webhookUrl: trimmed(webhookUrl),
                eventTypes: eventTypes
            )

            await load(businessId: businessId)
            return true

        } catch {
            errorMessage = userMessage(
                from: error,
                fallback: ConstantStrings.slackIntegrationUpdateFailed
            )
            return false
        }
    }

    private func validate(
        label: String,
        webhookUrl: String,
        eventTypes: [SlackActivityType]
    ) -> Bool {
        if trimmed(label).isEmpty {
            errorMessage = ConstantStrings.slackChannelNameRequired
            return false
        }

        if trimmed(webhookUrl).isEmpty {
            errorMessage = ConstantStrings.slackWebhookURLRequired
            return false
        }

        if eventTypes.isEmpty {
            errorMessage = ConstantStrings.slackActivityTypeRequired
            return false
        }

        errorMessage = nil
        return true
    }

    private func trimmed(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func userMessage(
        from error: Error,
        fallback: String
    ) -> String {
        if case let RepositoryError.api(message) = error {
            return message
        }

        return fallback
    }
}
