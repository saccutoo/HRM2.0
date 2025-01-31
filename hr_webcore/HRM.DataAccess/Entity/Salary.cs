//------------------------------------------------------------------------------
// <auto-generated>
//     This code was generated from a template.
//
//     Manual changes to this file may cause unexpected behavior in your application.
//     Manual changes to this file will be overwritten if the code is regenerated.
// </auto-generated>
//------------------------------------------------------------------------------

namespace HRM.DataAccess.Entity
{
    using System;
    using System.Collections.Generic;
    
    public partial class Salary
    {
        public int SalaryID { get; set; }
        public int Month { get; set; }
        public int Year { get; set; }
        public int StaffID { get; set; }
        public int? Period { get; set; }
        public DateTime? CreateDate { get; set; }
        public int Status { get; set; }
        public int? CreateBy { get; set; }
        public double? WorkdayPrevious { get; set; }
        public double? WorkdayAfter { get; set; }
        public double? Workingday { get; set; }
        public double? TimeLate { get; set; }
        public double? Decemberbonus { get; set; }
        public double? Standardworkingday { get; set; }
        public double? BasicSalary { get; set; }
        public double? Bonus { get; set; }
        public double? SeniorityPay { get; set; }
        public double? AllowancesLaptop { get; set; }
        public double? AllowancesPhone { get; set; }
        public double? BDOAllowances { get; set; }
        public double? OtherAllowances { get; set; }
        public string AllowancesNote { get; set; }
        public double? IncomePerDay { get; set; }
        public double? SalarylastMonth { get; set; }
        public double? Commission { get; set; }
        public double? OtherBonus { get; set; }
        public string BonusNote { get; set; }
        public double? PersonalIncomeTax { get; set; }
        public double? AmountInsurance { get; set; }
        public double? C_Socialinsurance { get; set; }
        public double? C_Healthinsurance { get; set; }
        public double? C_Unemploymentinsurance { get; set; }
        public double? C_KPCD { get; set; }
        public double? P_Socialinsurance { get; set; }
        public double? P_Healthinsurance { get; set; }
        public double? P_Unemploymentinsurance { get; set; }
        public double? P_KPCD { get; set; }
        public double? Deductionitself { get; set; }
        public double? NumRelatedperson { get; set; }
        public double? Deduction { get; set; }
        public double? Foodexpenses { get; set; }
        public double? Taxableincome { get; set; }
        public double? Nontaxableincome { get; set; }
        public string NontaxableincomeNote { get; set; }
        public double? UnionFund { get; set; }
        public double? TardinessReduction { get; set; }
        public double? QCBonus { get; set; }
        public double? AdvancePayment { get; set; }
        public double? OtherReduction { get; set; }
        public string ReductionNote { get; set; }
        public double? TotalIncome { get; set; }
        public double? TotalReduction { get; set; }
        public double? Netsalary { get; set; }

        public double? Margincompensation { get; set; }
        public string MargincompensationNote { get; set; }
        public double? PaymentPeriod1 { get; set; }
        public double? PaymentPeriod2 { get; set; }
        public double? PaymentPeriod3 { get; set; }
        public double? PaymentPeriod4 { get; set; }
        public double? PaymentPeriod5 { get; set; }
        public double? PaymentNextMonth { get; set; }
        public int? ModifiedBy { get; set; }
        public DateTime? ModifiedDate { get; set; }
        public double? AllowancesPosition { set; get; }
        public double? Allowancesparkingfee { set; get; }
        public bool Locked { set; get; }
        public double? OverTime { set; get; }
        public double? WorkingAdjusted { set; get; }
        public string NoteAdjusted { set; get; }
        public double SysBonus { set; get; }
        public double BonusSysCal { set; get; }

        public double BonusKPIYear { set; get; }
        public double OtherKPIYear { set; get; }

    }
}
