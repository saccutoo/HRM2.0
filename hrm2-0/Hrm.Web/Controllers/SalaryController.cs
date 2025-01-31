﻿using Hrm.Common;
using Hrm.Common.Helpers;
using Hrm.Framework.Controllers;
using Hrm.Framework.Helper;
using Hrm.Framework.Helpers;
using Hrm.Framework.Models;
using Hrm.Repository.Entity;
using Hrm.Repository.Type;
using Hrm.Service;
using Hrm.Web.ViewModels;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using Hrm.Web.Models;

namespace Hrm.Web.Controllers
{
    public class SalaryController : BaseController
    {
        private long _languageId;
        private long _userId;
        private long _roleId;
        private ITableColumnService _tableColumnService;
        private IMasterDataService _masterDataService;
        private ITableConfigService _tableConfigService;
        private ISalaryService _salaryService;
        private ISalaryElementService _salaryElementService;
        private IStaffService _staffService;
        private IOrganizationService _organizationService;
        private ILocalizationService _localizationService;

        public SalaryController(ITableColumnService tableColumnService, IMasterDataService masterDataService, ITableConfigService tableConfigService, ISalaryService salaryService, ISalaryElementService salaryElementService, IStaffService staffService, IOrganizationService organizationService, ILocalizationService localizationService)
        {
            _masterDataService = masterDataService;
            _tableColumnService = tableColumnService;
            _tableConfigService = tableConfigService;
            _salaryService = salaryService;
            _salaryElementService = salaryElementService;
            _staffService = staffService;
            _organizationService = organizationService;
            _localizationService = localizationService;
            this._languageId = CurrentUser.LanguageId;
            this._userId = CurrentUser.UserId;
            this._roleId = CurrentUser.RoleId;
        }

        public ActionResult SalaryPaySlip()
        {
            GeneralnformationAndSalaryViewModel generalnformationAndDetailSalary_vm = new GeneralnformationAndSalaryViewModel();
            generalnformationAndDetailSalary_vm.Month = DateTime.Now.Month;
            generalnformationAndDetailSalary_vm.Year = DateTime.Now.Year;
            generalnformationAndDetailSalary_vm.StaffId = 0;

            var resultTableConfig = this._tableConfigService.GetTableConfigByTableName(TableConfig.Salary);
            var tableConfigDetail = JsonConvert.DeserializeObject<HrmResultModel<TableConfigModel>>(resultTableConfig);
            if (!CheckPermission(tableConfigDetail))
            {
                //return to Access Denied
            }
            else
            {
                var dataTableConfig = new TableViewModel();
                if (tableConfigDetail.Results.FirstOrDefault() != null)
                {
                    dataTableConfig = JsonConvert.DeserializeObject<TableViewModel>(tableConfigDetail.Results.FirstOrDefault().ConfigData);
                   var param = new BasicParamModel()
                    {
                        FilterField = "",
                        PageNumber = 1,
                        StringJson = "{Month:" + DateTime.Now.Month + ",Year:" + DateTime.Now.Year + ",StaffId:" + 0 + ",OrganizationId:"+0+ "}",
                        PageSize = dataTableConfig.ItemsPerPage,
                        LanguageId = _languageId,
                        DbName = CurrentUser.DbName
                    };
                    dataTableConfig.TableConfigName = TableConfig.Salary;
                    dataTableConfig.TableDataUrl = TableUrl.TableSalary;
                    generalnformationAndDetailSalary_vm.Salary.Table = RenderTable(dataTableConfig, param, TableName.TableSalary);
                }
            }
            var lstStaff = _staffService.GetStaffByParentId(CurrentUser.UserId);
            if (lstStaff != null)
            {
                var resultStaff = JsonConvert.DeserializeObject<HrmResultModel<StaffModel>>(lstStaff);
                if (!CheckPermission(resultStaff))
                {
                    //return to Access Denied
                }
                else
                {
                    if (resultStaff.Results.Count() > 0)
                    {
                        foreach (var item in resultStaff.Results)
                        {
                            var stringFormat = item.OrganizationId.ToString() + ";" + DataType.Organization + ";OrganizationName";
                            item.Name = item.Name + " - " + _localizationService.GetLocalizedData(stringFormat).ToString();
                        }
                        generalnformationAndDetailSalary_vm.Staffs = JsonConvert.DeserializeObject<List<dynamic>>(JsonConvert.SerializeObject(resultStaff.Results));
                    }
                }
            }

            var responseOrganization = _organizationService.GetOrganizationByParentId(CurrentUser.UserId);
            if (responseOrganization != null)
            {
                var resultOrganization = JsonConvert.DeserializeObject<HrmResultModel<OrganizationModel>>(responseOrganization);
                if (!CheckPermission(resultOrganization))
                {
                    //return to Access Denied
                }
                else
                {
                    generalnformationAndDetailSalary_vm.Organizations = JsonConvert.DeserializeObject<List<dynamic>>(JsonConvert.SerializeObject(resultOrganization.Results));
                }
            }
            return View(generalnformationAndDetailSalary_vm);
        }

        public ActionResult showSalaryPaySlip(long staffId,int month,int year)
        {
            SalaryPaySlipViewModel salaryPaySlip = new SalaryPaySlipViewModel();
            salaryPaySlip.IsViewOrder = false;
            salaryPaySlip.IsSave = false;
            salaryPaySlip.IsShow = true;
            if (month==0)
            {
                month = DateTime.Now.Month;
            }
            if (year == 0)
            {
                year = DateTime.Now.Year;
            }
            var responseSalaryElement = _salaryElementService.GetSalaryElementByStaffMonthYear(staffId, month, year);
            if (responseSalaryElement != null)
            {
                var resultSalaryElement = JsonConvert.DeserializeObject<HrmResultModel<SalaryElementModel>>(responseSalaryElement);
                if (!CheckPermission(resultSalaryElement))
                {
                    //return to Access Denied
                }
                else
                {
                    salaryPaySlip.SalaryElements = resultSalaryElement.Results;
                }
            }
            var responseStaff = _staffService.GetStaffInfomationForReplaceSalaryPaySlip(staffId, month, year);
            if (responseStaff!=null)
            {
                var resultStaff= JsonConvert.DeserializeObject<HrmResultModel<StaffModel>>(responseStaff);
                if (!CheckPermission(resultStaff))
                {
                    //return to Access Denied
                }
                else
                {
                    salaryPaySlip.Staff = JsonConvert.DeserializeObject<dynamic>(JsonConvert.SerializeObject(resultStaff.Results.FirstOrDefault()));
                }
            }

            return PartialView(UrlHelpers.View("~/Views/Shared/_SalaryPaySlip.cshtml"), salaryPaySlip);
        }

        #region RenderTable
        public ActionResult GetData(TableViewModel tableData, BasicParamModel param)
        {
            tableData = RenderTable(tableData, param, tableData.TableName);
            return View(UrlHelpers.Template("_TableContent.cshtml"), tableData);
        }
        public TableViewModel RenderTable(TableViewModel tableData, BasicParamModel param, string type)
        {
            var result = new TableViewModel();
            result = tableData;
            //model param
            int totalRecord = 0;
            param.LanguageId = _languageId;
            param.UserId = _userId;
            param.RoleId = _roleId;
            param.DbName = CurrentUser.DbName;
            var outTotalJson = string.Empty;
            //Gọi hàm lấy thông tin 

            var response = GetData(type, param, out outTotalJson, out totalRecord);
            result.CurrentPage = param.PageNumber;
            result.ItemsPerPage = param.PageSize;
            result.TotalRecord = totalRecord;
            if (outTotalJson != string.Empty && outTotalJson != null && outTotalJson != "")
            {
                result.Total = JsonConvert.DeserializeObject<dynamic>(outTotalJson);
            }
            if (type == TableName.TableSalary)
            {
                if (response != null)
                {
                    var resultData = JsonConvert.DeserializeObject<HrmResultModel<SalaryModel>>(response);
                    if (!CheckPermission(resultData))
                    {
                        //return to Access Denied
                    }
                    else
                    {
                        result.TableData = JsonConvert.DeserializeObject<List<dynamic>>(JsonConvert.SerializeObject(resultData.Results));
                    }
                }
                result.TableName = TableName.TableSalary;
                result.TableConfigName = TableConfig.Salary;

            }

            var responseColumn = this._tableColumnService.GetTableColumn(result.TableConfigName);
            if (responseColumn != null)
            {
                var resultColumn = JsonConvert.DeserializeObject<HrmResultModel<TableColumnModel>>(responseColumn);
                if (!CheckPermission(resultColumn))
                {
                    //return to Access Denied
                }
                else
                {
                    result.ListTableColumns = resultColumn.Results;
                }
            }

            var resultMasterDataSelectList = this._masterDataService.GetAllMasterDataByName(MasterGroup.ItemsPerPage, _languageId);
            var resultSelectList = JsonConvert.DeserializeObject<HrmResultModel<MasterDataModel>>(resultMasterDataSelectList);
            if (!CheckPermission(resultSelectList))
            {
                //return to Access Denied
            }
            else
            {
                var dataSelectList = resultSelectList.Results;
                var dataDropdownList = MapperHelper.MapList<MasterDataModel, DropdownListContentModel>(dataSelectList);
                foreach (var item in dataDropdownList)
                {
                    if (Convert.ToInt32(item.Value) == param.PageSize)
                    {
                        item.IsSelected = true;
                        break;
                    }
                }
                List<dynamic> dataDropDownListDynamic = JsonConvert.DeserializeObject<List<dynamic>>(JsonConvert.SerializeObject(dataDropdownList));
                result.lstItemsPerPage = dataDropDownListDynamic;
            }

            return result;
        }
        private string GetData(string tableName, BasicParamModel param, out string outTotalJson, out int totalRecord)
        {
            int year = DateTime.Now.Year;
            int month = DateTime.Now.Month;
            long staffId = 0;
            long organizationId = 0;
            if (!String.IsNullOrEmpty(param.StringJson) && param.StringJson != null && param.StringJson!= "")
            {
                var dynamic = JsonConvert.DeserializeObject<dynamic>(param.StringJson);
                month = Convert.ToInt32(dynamic["Month"]);
                year = Convert.ToInt32(dynamic["Year"]);
                staffId = Convert.ToInt32(dynamic["StaffId"]);
                organizationId = Convert.ToInt32(dynamic["OrganizationId"]);
                if (staffId != 0)
                {
                    param.FilterField = "AND DSI.Id=" + staffId;
                }
               
                if (organizationId!=0)
                {
                    if (param.FilterField!=string.Empty && param.FilterField!=null && param.FilterField!="")
                    {
                        param.FilterField += " AND DSWP.OrganizationId=" + organizationId;
                    }
                    else
                    {
                        param.FilterField = " AND DSWP.OrganizationId=" + organizationId;
                    }
                }
            }
            var paramEntity = MapperHelper.Map<BasicParamModel, BasicParamType>(param);

            if (tableName == TableName.TableSalary)
            {
                
                return _salaryService.GetSalary(paramEntity, month,year,staffId, out outTotalJson, out totalRecord);
            }
            totalRecord = 0;
            outTotalJson = string.Empty;
            return string.Empty;
        }
        #endregion
    }
}