﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Hrm.Framework.Models
{
    public class AttachmentJs
    {
        public long Id { get; set; }
        public string Name { get; set; }
        public string Realname { get; set; }
        public string Extension { get; set; }
        public float Size { get; set; }
        public string CreatedDate { get; set; }
    }
}
