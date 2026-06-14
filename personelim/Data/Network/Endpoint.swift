import Foundation

enum Endpoint {

    case login
    case register
    case forgotPassword
    case verifyResetCode
    case resetPassword

    case verifyBusiness
    case createBusiness
    case getBusiness(businessId: String)
    case business
    case businessList
    case updateBusiness(businessId: String)
    case uploadBusinessDocument(businessId: String)
    case getBusinessDocuments(businessId: String)
    case deleteBusinessDocument(documentId: String)
    case subscribeBusiness(businessId: String)
    case deleteBusiness(businessId: String)

    case businessMembers(businessId: String)
    case getBusinessMember(memberId: String)
    case updateBusinessMember(memberId: String)
    case addBusinessMember
    case deleteBusinessMember(memberId: String)
    case uploadMemberDocuments(memberId: String)
    case updateMemberDocument(documentId: String)
    case deleteMemberDocument(documentId: String)
    case downloadDocument(documentId: String)

    case profile
    case profileUpdate
    case deleteAccount

    case provinces
    case districts(provinceId: Int)

    case sendInvitation

    case myTasks
    case createTask
    case updateTaskStatus(taskId: String)
    case deleteTask(taskId: String)

    case schedules(businessId: String)
    case createSchedule
    case deleteSchedule(scheduleId: String)

    case performanceQuery
    case performanceReports(businessId: String, employeeUserId: String)
    case performanceReportDetail(reportId: String)
    case performanceQueryBulkScores
    case performanceQueryDepartment
    case performanceQueryDepartmentCharts
    case queryDepartmentCharts

    case createShift
    case myShifts(businessId: String)

    case createLeave
    case myLeaves(businessId: String)
    case businessLeaves(businessId: String)
    case updateLeaveStatus(leaveId: String)
    case deleteLeave(leaveId: String)

    case departments(businessId: String)
    case createDepartment
    case updateDepartment(id: String)
    case deleteDepartment(id: String)

    case jobTitleCategories
    case jobCategories
    case jobTitlesByDepartment(departmentId: String)

    case slackWebhooks(businessId: String)
    case createSlackWebhook
    case updateSlackWebhook(id: String)
    case deleteSlackWebhook(id: String)
    case slackWebhookEventTypes

    case departmentPerformanceHistory(businessId: String, departmentId: String)
    case departmentReportsByBusiness(businessId: String)
    case departmentReportDetail(reportId: String)

    case logout

    case chatPersonel
    case chatYonetici
    case chatConversations
    case chatConversationDetail(conversationId: String)
    case deleteChatConversation(conversationId: String)
    case unsubscribeBusiness(businessId: String)

    var path: String {
        switch self {

        case .login:
            return "/api/Auth/login"

        case .register:
            return "/api/Auth/register"

        case .forgotPassword:
            return "/api/Auth/forgot-password"

        case .verifyResetCode:
            return "/api/Auth/verify-reset-code"

        case .resetPassword:
            return "/api/Auth/reset-password"

        case .logout:
            return "/api/Auth/logout"

        case .verifyBusiness:
            return "/api/Business/verify"

        case .createBusiness:
            return "/api/Business/create-business"

        case .business:
            return "/api/Business"

        case .businessList:
            return "/api/Business"

        case let .getBusiness(businessId):
            return "/api/Business/\(businessId)"

        case let .updateBusiness(businessId):
            return "/api/Business/\(businessId)"

        case let .uploadBusinessDocument(businessId):
            return "/api/Business/\(businessId)/documents"

        case let .getBusinessDocuments(businessId):
            return "/api/Business/\(businessId)/documents"

        case let .deleteBusinessDocument(documentId):
            return "/api/Business/documents/\(documentId)"

        case let .subscribeBusiness(businessId):
            return "/api/Business/\(businessId)/subscribe"

        case let .deleteBusiness(businessId):
            return "/api/Business/\(businessId)"

        case let .businessMembers(businessId):
            return "/api/BusinessMember/business/\(businessId)"

        case let .getBusinessMember(memberId):
            return "/api/BusinessMember/\(memberId)"

        case let .updateBusinessMember(memberId):
            return "/api/BusinessMember/\(memberId)"

        case .addBusinessMember:
            return "/api/BusinessMember/add"

        case let .deleteBusinessMember(memberId):
            return "/api/BusinessMember/\(memberId)"

        case let .uploadMemberDocuments(memberId):
            return "/api/BusinessMember/\(memberId)/documents"

        case let .updateMemberDocument(documentId):
            return "/api/BusinessMember/documents/\(documentId)"

        case let .deleteMemberDocument(documentId):
            return "/api/BusinessMember/documents/\(documentId)"

        case let .downloadDocument(documentId):
            return "/api/BusinessMember/documents/\(documentId)/download"

        case .profile:
            return "/api/Profile"

        case .profileUpdate:
            return "/api/profile"

        case .deleteAccount:
            return "/api/Profile/delete-account"

        case .provinces:
            return "/api/Location/provinces"

        case let .districts(provinceId):
            return "/api/Location/provinces/\(provinceId)/districts"

        case .sendInvitation:
            return "/api/Invitation/send"

        case .myTasks:
            return "/api/Task/my-tasks"

        case .createTask:
            return "/api/Task/create"

        case let .updateTaskStatus(taskId):
            return "/api/Task/\(taskId)/status"

        case let .deleteTask(taskId):
            return "/api/Task/\(taskId)"

        case let .schedules(businessId):
            return "/api/schedules/\(businessId)"

        case .createSchedule:
            return "/api/schedules"

        case let .deleteSchedule(scheduleId):
            return "/api/schedules/\(scheduleId)"

        case .performanceQuery:
            return "/api/Performance/query"

        case let .performanceReports(businessId, employeeUserId):
            return "/api/Performance/business/\(businessId)/employee/\(employeeUserId)"

        case let .performanceReportDetail(reportId):
            return "/api/Performance/\(reportId)"

        case .performanceQueryBulkScores:
            return "/api/Performance/query-bulk-scores"

        case .performanceQueryDepartment:
            return "/api/Performance/query-department"

        case .performanceQueryDepartmentCharts:
            return "/api/Performance/query-department-charts"

        case .queryDepartmentCharts:
            return "/api/Performance/query-department-charts"

        case let .departmentPerformanceHistory(businessId, departmentId):
            return "/api/Performance/business/\(businessId)/department/\(departmentId)"

        case let .departmentReportsByBusiness(businessId):
            return "/api/Performance/department-reports/business/\(businessId)"

        case let .departmentReportDetail(reportId):
            return "/api/Performance/department-reports/\(reportId)"

        case .createShift:
            return "/api/Shift"

        case let .myShifts(businessId):
            return "/api/Shift/my?businessId=\(businessId)"

        case .createLeave:
            return "/api/Leave"

        case let .myLeaves(businessId):
            return "/api/Leave/my-leaves/\(businessId)"

        case let .businessLeaves(businessId):
            return "/api/Leave/business/\(businessId)"

        case let .updateLeaveStatus(leaveId):
            return "/api/Leave/\(leaveId)/status"

        case let .deleteLeave(leaveId):
            return "/api/Leave/\(leaveId)"

        case let .departments(businessId):
            return "/api/Department/business/\(businessId)"

        case .createDepartment:
            return "/api/Department"

        case let .updateDepartment(id):
            return "/api/Department/\(id)"

        case let .deleteDepartment(id):
            return "/api/Department/\(id)"

        case .jobTitleCategories:
            return "/api/job-titles/categories"

        case .jobCategories:
            return "/api/JobTitles/categories"

        case let .jobTitlesByDepartment(departmentId):
            return "/api/JobTitles/by-department/\(departmentId)"

        case let .slackWebhooks(businessId):
            return "/api/SlackWebhooks/\(businessId)"

        case .createSlackWebhook:
            return "/api/SlackWebhooks"

        case let .updateSlackWebhook(id):
            return "/api/SlackWebhooks/\(id)"

        case let .deleteSlackWebhook(id):
            return "/api/SlackWebhooks/\(id)"

        case .slackWebhookEventTypes:
            return "/api/SlackWebhooks/event-types"

        case .chatPersonel:
            return "/api/Chat/personel"

        case .chatYonetici:
            return "/api/Chat/yonetici"

        case .chatConversations:
            return "/api/Chat/conversations"

        case let .chatConversationDetail(conversationId):
            return "/api/Chat/conversations/\(conversationId)"

        case let .deleteChatConversation(conversationId):
            return "/api/Chat/conversations/\(conversationId)"
            
        case .unsubscribeBusiness(let businessId):
            return "/api/Business/\(businessId)/unsubscribe"
        }
    }

    var method: HTTPMethod {
        switch self {

        case .login,
             .register,
             .forgotPassword,
             .verifyResetCode,
             .resetPassword,
             .verifyBusiness,
             .createBusiness,
             .uploadMemberDocuments,
             .createTask,
             .createSchedule,
             .uploadBusinessDocument,
             .subscribeBusiness,
             .sendInvitation,
             .performanceQuery,
             .createShift,
             .performanceQueryBulkScores,
             .createLeave,
             .createDepartment,
             .addBusinessMember,
             .updateMemberDocument,
             .createSlackWebhook,
             .performanceQueryDepartment,
             .performanceQueryDepartmentCharts,
             .queryDepartmentCharts,
             .logout,
             .chatPersonel,
             .chatYonetici,
             .unsubscribeBusiness:
            return .post

        case .businessMembers,
             .profile,
             .getBusiness,
             .provinces,
             .districts,
             .business,
             .businessList,
             .getBusinessMember,
             .downloadDocument,
             .myTasks,
             .schedules,
             .getBusinessDocuments,
             .performanceReports,
             .performanceReportDetail,
             .myShifts,
             .myLeaves,
             .businessLeaves,
             .departments,
             .jobTitleCategories,
             .jobCategories,
             .jobTitlesByDepartment,
             .slackWebhooks,
             .slackWebhookEventTypes,
             .departmentPerformanceHistory,
             .departmentReportsByBusiness,
             .departmentReportDetail,
             .chatConversations,
             .chatConversationDetail:
            return .get

        case .profileUpdate,
             .updateBusinessMember,
             .updateBusiness,
             .updateTaskStatus,
             .updateLeaveStatus,
             .updateDepartment,
             .updateSlackWebhook:
            return .put

        case .deleteBusinessDocument,
             .deleteMemberDocument,
             .deleteBusiness,
             .deleteBusinessMember,
             .deleteAccount,
             .deleteLeave,
             .deleteTask,
             .deleteSchedule,
             .deleteDepartment,
             .deleteSlackWebhook,
             .deleteChatConversation:
            return .delete
        }
    }
}
