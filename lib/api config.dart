library APIConstants;

var baseUrl = "http://182.18.157.215/HRMS/API"; //           url
//var baseUrl = "http://182.18.157.215/BHRMS/API"; // beta version url
//var baseUrl = "http://hrms.calibrage.in/api"; // live url
var getlogin = "/hrmsapi/Security/Login"; // login url post api

var getselfempolyee = "/hrmsapi/Employee/GetSelfEmployeeData/"; // need to pass the empolyeeid
//http://182.18.157.215/HRMS/API/hrmsapi/Attendance/CreateEmployeeLeave
var applyleaveapi = "/hrmsapi/Attendance/CreateEmployeeLeave"; //post api
var getquestions = '/hrmsapi/Security/ValidateUserQuestions/'; // pass the username
var changepassword = '/hrmsapi/Security/Forgotpassword';
var getleavesapi = "/hrmsapi/Attendance/GetLeavesForSelfEmployee/";
var getmontlyleaves = "/hrmsapi/Attendance/GetLeavesForSelfInMonth"; //parameter months id, employeid
var GetHolidayList = "/hrmsapi/Admin/GetHolidays/";
var getdropdown = "/hrmsapi/Lookup/LookupDetails/";
var lookupkeys = "/hrmsapi/Lookup/LookupKeys";
var GetEmployeePhoto = "/hrmsapi/Employee/GetEmployeePhoto/";
var sendingquestionapi = "/hrmsapi/Security/CreateUserQuestion";
var addquestionsuser = "/hrmsapi/Security/UpdateUserOnFirstLogin";
var fetchquestion = '/hrmsapi/Security/SecureQuestions';
var deleteleave = '/hrmsapi/Attendance/DeleteLeave'; //pass the employeeleaveid
var feedbackapi = '/hrmsapi/Admin/UpdateFeedback'; //post api
var getprojectemployeslist = '/hrmsapi/Employee/GetProjectsForSelfEmployee/'; //pass the employeeid
var getadminsettings = '/hrmsapi/AdminDashboard/GetAppSettings';
var getnotification = '/hrmsapi/Notification/GetNotifications';
var sendgreeting = '/hrmsapi/Notification/CreateNotificationReplies';
var getnotificationreplies = '/hrmsapi/Notification/GetNotificationReplies/';
var getupcomingbirthdays = '/hrmsapi/Notification/GetUpcomingBirthdaysNotifications';
var getResignations = '/hrmsapi/Resignation/GetResignations';
var applyResignation = '/hrmsapi/Resignation/CreateResignationRequest';
var WithdrawResignation = '/hrmsapi/Resignation/RejectResignationRequest';
