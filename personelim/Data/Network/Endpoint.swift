//
//  Endpoint.swift
//  personelim
//
//  Created by Tuğberk Acabey on 23.11.2025.
//

import Foundation

enum Endpoint {
    case login
    case register
    case forgotPassword
    case verifyResetCode
    case resetPassword
    case verifyBusiness
    case createBusiness
    case businessMembers(businessId: String)
    case getBusiness(businessId: String)
    case provinces
    case districts(provinceId: Int)
    case profileUpdate
    case profile
    case business
    case businessList
    case uploadMemberDocuments(memberId: String)
    case getBusinessMember(memberId: String)
    case updateBusinessMember(memberId: String)
    case downloadDocument(documentId: String)
    case myTasks
    case createTask
    case updateTaskStatus(taskId: String)
    case updateBusiness(businessId: String)
    case uploadBusinessDocument(businessId: String)
    case getBusinessDocuments(businessId: String)
    case deleteBusinessDocument(documentId: String)
    case deleteMemberDocument(documentId: String)
    case deleteBusiness(businessId: String)
    case deleteBusinessMember(memberId: String)
    case deleteAccount
    case sendInvitation
    case performanceQuery
    case performanceReports(businessId: String, employeeUserId: String)
    case performanceReportDetail(reportId: String)
    case createShift
    case myShifts(businessId: String)
    case performanceQueryBulkScores
    case createLeave
    case myLeaves(businessId: String)
    case businessLeaves(businessId: String)
    case updateLeaveStatus(leaveId: String)
    case deleteLeave(leaveId: String)

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
        case .profileUpdate: return "/api/Auth/profile"
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
        case .uploadBusinessDocument(let businessId): return "/api/Business/\(businessId)/documents"
        case .getBusinessDocuments(let businessId): return "/api/Business/\(businessId)/documents"
        case .deleteBusinessDocument(let documentId): return "/api/Business/documents/\(documentId)"
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
            

        }
    }

    var method: HTTPMethod {
        switch self {
        case .login, .register, .forgotPassword, .verifyResetCode, .resetPassword, .verifyBusiness, .createBusiness, .uploadMemberDocuments, .createTask, .uploadBusinessDocument, .sendInvitation, .performanceQuery, .createShift, .performanceQueryBulkScores, .createLeave:
            return .post

        case .businessMembers, .profile, .getBusiness, .provinces, .districts, .business, .businessList, .getBusinessMember, .downloadDocument, .myTasks, .getBusinessDocuments, .performanceReports, .performanceReportDetail, .myShifts, .myLeaves, .businessLeaves:
            return .get

        case .profileUpdate, .updateBusinessMember, .updateBusiness, .updateTaskStatus, .updateLeaveStatus:
            return .put
            
        case .deleteBusinessDocument,
             .deleteMemberDocument,
             .deleteBusiness,
             .deleteBusinessMember,
             .deleteAccount,
             .deleteLeave:
        return .delete
        }
    }
}
