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
    
    public partial class SalarySourceConfig
    {
        public int SalarySourceConfigId { get; set; }
        public string SalarySourceConfigName { get; set; }
        public int EmpId { get; set; }
        public int SalarySourceId { get; set; }
        public System.DateTime StartDate { get; set; }
        public System.DateTime EndDate { get; set; }
        public int Status { get; set; }
        public double Value { get; set; }
        public string Formula { get; set; }
    }
}
