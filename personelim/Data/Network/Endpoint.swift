import Foundation

enum Endpoint {
    // MARK: - Auth
    case login
    case register
    case forgotPassword
    case verifyResetCode
    case resetPassword

    // MARK: - Business
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

    // MARK: - Business Member
    case businessMembers(businessId: String)
    case getBusinessMember(memberId: String)
    case updateBusinessMember(memberId: String)
    case addBusinessMember
    case deleteBusinessMember(memberId: String)
    case uploadMemberDocuments(memberId: String)
    case updateMemberDocument(documentId: String)
    case deleteMemberDocument(documentId: String)
    case downloadDocument(documentId: String)

    // MARK: - Profile
    case profile
    case profileUpdate
    case deleteAccount

    // MARK: - Location
    case provinces
    case districts(provinceId: Int)

    // MARK: - Invitation
    case sendInvitation

    // MARK: - Task
    case myTasks
    case createTask
    case updateTaskStatus(taskId: String)
    case deleteTask(taskId: String)

    // MARK: - Schedule
    case schedules(businessId: String)
    case createSchedule
    case deleteSchedule(scheduleId: String)

    // MARK: - Performance
    case performanceQuery
    case performanceReports(businessId: String, employeeUserId: String)
    case performanceReportDetail(reportId: String)
    case performanceQueryBulkScores
    case performanceQueryDepartment

    // MARK: - Shift
    case createShift
    case myShifts(businessId: String)

    // MARK: - Leave
    case createLeave
    case myLeaves(businessId: String)
    case businessLeaves(businessId: String)
    case updateLeaveStatus(leaveId: String)
    case deleteLeave(leaveId: String)

    // MARK: - Department
    case departments(businessId: String)
    case createDepartment
    case updateDepartment(id: String)
    case deleteDepartment(id: String)

    // MARK: - Job Titles
    case jobTitleCategories
    case jobCategories
    case jobTitlesByDepartment(departmentId: String)

    // MARK: - Slack Integration
    case slackWebhooks(businessId: String)
    case createSlackWebhook
    case updateSlackWebhook(id: String)
    case deleteSlackWebhook(id: String)
    case slackWebhookEventTypes
    
    case performanceQueryDepartmentCharts
    case queryDepartmentCharts
    
    case departmentPerformanceHistory(
        businessId: String,
        departmentId: String
    )
    
    case departmentReportsByBusiness(businessId: String)
    case departmentReportDetail(reportId: String)
    
    case logout

    var path: String {
        switch self {
        case .login: return "/api/Auth/login"
        case .register: return "/api/Auth/register"
        case .forgotPassword: return "/api/Auth/forgot-password"
        case .verifyResetCode: return "/api/Auth/verify-reset-code"
        case .resetPassword: return "/api/Auth/reset-password"
        case .verifyBusiness: return "/api/Business/verify"
        case .createBusiness: return "/api/Business/create-business"
        case .businessMembers(let businessId): return "/api/BusinessMember/business/\(businessId)"
        case .profile: return "/api/Profile"
        case .getBusiness(let businessId): return "/api/Business/\(businessId)"
        case .provinces: return "/api/Location/provinces"
        case .districts(let provinceId): return "/api/Location/provinces/\(provinceId)/districts"
        case .profileUpdate: return "/api/profile"
        case .business: return "/api/Business"
        case .businessList: return "/api/Business"
        case .uploadMemberDocuments(let memberId): return "/api/BusinessMember/\(memberId)/documents"
        case .getBusinessMember(let memberId): return "/api/BusinessMember/\(memberId)"
        case .updateBusinessMember(let memberId): return "/api/BusinessMember/\(memberId)"
        case .downloadDocument(let documentId): return "/api/BusinessMember/documents/\(documentId)/download"
        case .updateBusiness(let id): return "/api/Business/\(id)"
        case .myTasks: return "/api/Task/my-tasks"
        case .createTask: return "/api/Task/create"
        case .updateTaskStatus(let taskId): return "/api/Task/\(taskId)/status"
        case .schedules(let businessId): return "/api/schedules/\(businessId)"
        case .createSchedule: return "/api/schedules"
        case .deleteTask(let taskId): return "/api/Task/\(taskId)"
        case .deleteSchedule(let scheduleId): return "/api/schedules/\(scheduleId)"
        case .uploadBusinessDocument(let businessId): return "/api/Business/\(businessId)/documents"
        case .getBusinessDocuments(let businessId): return "/api/Business/\(businessId)/documents"
        case .deleteBusinessDocument(let documentId): return "/api/Business/documents/\(documentId)"
        case .subscribeBusiness(let businessId): return "/api/Business/\(businessId)/subscribe"
        case .deleteMemberDocument(let documentId): return "/api/BusinessMember/documents/\(documentId)"
        case .deleteBusiness(let businessId): return "/api/Business/\(businessId)"
        case .deleteBusinessMember(let memberId): return "/api/BusinessMember/\(memberId)"
        case .deleteAccount: return "/api/Auth/delete-account"
        case .sendInvitation: return "/api/Invitation/send"
        case .performanceQuery: return "/api/Performance/query"
        case .performanceReports(let businessId, let employeeUserId): return "/api/Performance/business/\(businessId)/employee/\(employeeUserId)"
        case .performanceReportDetail(let reportId): return "/api/Performance/\(reportId)"
        case .createShift: return "/api/Shift"
        case .performanceQueryBulkScores: return "/api/Performance/query-bulk-scores"
        case .myShifts(let businessId): return "/api/Shift/my?businessId=\(businessId)"
        case .createLeave: return "/api/Leave"
        case .myLeaves(let businessId): return "/api/Leave/my-leaves/\(businessId)"
        case .businessLeaves(let businessId): return "/api/Leave/business/\(businessId)"
        case .updateLeaveStatus(let leaveId): return "/api/Leave/\(leaveId)/status"
        case .deleteLeave(let leaveId): return "/api/Leave/\(leaveId)"
            
        case .departments(let businessId): return "/api/Department/business/\(businessId)"
        case .createDepartment: return "/api/Department"
        case .jobTitleCategories: return "/api/job-titles/categories"
            
        case .jobCategories:
            return "/api/JobTitles/categories"
            
        case .addBusinessMember:
                    return "/api/BusinessMember/add"
                case .updateMemberDocument(let id):
                    return "/api/BusinessMember/documents/\(id)"
            
        case .jobTitlesByDepartment(let id):
                    return "/api/JobTitles/by-department/\(id)"
            
        case .updateDepartment(let id): return "/api/Department/\(id)"
        case .deleteDepartment(let id): return "/api/Department/\(id)"
        case .slackWebhooks(let businessId): return "/api/SlackWebhooks/\(businessId)"
        case .createSlackWebhook: return "/api/SlackWebhooks"
        case .updateSlackWebhook(let id): return "/api/SlackWebhooks/\(id)"
        case .deleteSlackWebhook(let id): return "/api/SlackWebhooks/\(id)"
        case .slackWebhookEventTypes: return "/api/SlackWebhooks/event-types"
            
        case .performanceQueryDepartment: return "/api/Performance/query-department"
            
        case .performanceQueryDepartmentCharts:
            return "/api/Performance/query-department-charts"
            
        case .queryDepartmentCharts:
                return "/api/Performance/query-department-charts"

        case .logout:
            return "/api/Auth/logout"
            
        case let .departmentPerformanceHistory(
            businessId,
            departmentId
        ):
            return "/api/Performance/business/\(businessId)/department/\(departmentId)"
            
            
        case let .departmentReportsByBusiness(businessId):
            return "/api/Performance/department-reports/business/\(businessId)"

        case let .departmentReportDetail(reportId):
            return "/api/Performance/department-reports/\(reportId)"
                }
        
        
        
        
    }

    var method: HTTPMethod {
        switch self {
        case .login, .register, .forgotPassword, .verifyResetCode, .resetPassword, .verifyBusiness, .createBusiness, .uploadMemberDocuments, .createTask, .createSchedule, .uploadBusinessDocument, .subscribeBusiness, .sendInvitation, .performanceQuery, .createShift, .performanceQueryBulkScores, .createLeave, .createDepartment, .addBusinessMember, .updateMemberDocument, .createSlackWebhook,
                .performanceQueryDepartment, .performanceQueryDepartmentCharts, .queryDepartmentCharts, .logout: 
                    return .post

        case .businessMembers, .profile, .getBusiness, .provinces, .districts, .business, .businessList, .getBusinessMember, .downloadDocument, .myTasks, .schedules, .getBusinessDocuments, .performanceReports, .performanceReportDetail, .myShifts, .myLeaves, .businessLeaves, .departments, .jobTitleCategories, .jobCategories, .jobTitlesByDepartment, .slackWebhooks, .slackWebhookEventTypes,.departmentPerformanceHistory, .departmentReportsByBusiness, .departmentReportDetail:
            return .get

        case .profileUpdate, .updateBusinessMember, .updateBusiness, .updateTaskStatus, .updateLeaveStatus, .updateDepartment, .updateSlackWebhook:
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
             .deleteSlackWebhook
            :
            return .delete
        }
    }
}
