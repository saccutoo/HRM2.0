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
    
    public partial class Sys_Menu
    {
        public int Id { get; set; }
        public string MenuName { get; set; }
        public string MenuNameEn { get; set; }
        public Nullable<int> ParentId { get; set; }
        public System.DateTime CreateDate { get; set; }
        public int CreateBy { get; set; }
        public bool isActive { get; set; }
        public string Url { get; set; }
    }
}
