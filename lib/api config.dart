library APIConstants;

var baseUrl = "http://182.18.157.215/HRMS/API"; // test url

var getlogin = "/hrmsapi/Security/Login"; // login url post api

var getselfempolyee =
    "/hrmsapi/Employee/GetSelfEmployeeData/"; // need to pass the empolyeeid

var applyleaveapi =
    "/hrmsapi/Attendance/CreateEmployeeLeaveFromMobile"; //post api

var getleavesapi = "/hrmsapi/Attendance/GetLeavesForSelfEmployee/";
var getmontlyleaves =
    "/hrmsapi/Attendance/GetLeavesForSelfInMonth"; //parameter months id, employeid
