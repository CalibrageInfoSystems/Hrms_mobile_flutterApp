library APIConstants;

var baseUrl = "http://182.18.157.215/HRMS/API"; // test url
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
