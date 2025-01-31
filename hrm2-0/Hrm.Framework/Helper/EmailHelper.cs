﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Net.Mail;
using System.IO;
using System.Net;
using Hrm.Framework.Models;
using System.Configuration;

namespace Hrm.Framework.Helper
{
    public static class EmailHelper
    {
        public static EmailConfigModel GetConfiguration()
        {

            return new EmailConfigModel
            {
                SmtpServer = ConfigurationManager.AppSettings["SmtpServer"],
                MailUserName = ConfigurationManager.AppSettings["MailUserName"],
                MailPassword = ConfigurationManager.AppSettings["MailPassword"],
                EnableSsl = ConfigurationManager.AppSettings["EnableSsl"],
                MailPort = ConfigurationManager.AppSettings["MailPort"],
            };
        }
        public static int SendMail(string subject, string body, string from, IEnumerable<string> to, IEnumerable<string> cc, IEnumerable<string> bcc, IEnumerable<Attachment> attachments)
        {
            var emailConfiguration = GetConfiguration();

            if (emailConfiguration == null)
                return 404;

            try
            {
                emailConfiguration.MailFrom = from;
                using (var smtpClient = new SmtpClient
                {
                    Host = emailConfiguration.SmtpServer,
                    EnableSsl = bool.Parse(emailConfiguration.EnableSsl),
                })
                {

                    if (!string.IsNullOrEmpty(emailConfiguration.MailUserName) && !string.IsNullOrEmpty(emailConfiguration.MailPassword))
                    {
                        smtpClient.UseDefaultCredentials = false;
                        smtpClient.Credentials = new NetworkCredential(emailConfiguration.MailUserName, emailConfiguration.MailPassword);
                    }
                    else
                    {
                        smtpClient.UseDefaultCredentials = true;
                    }

                    if (!string.IsNullOrEmpty(emailConfiguration.MailPort))
                    {
                        smtpClient.Port = int.Parse(emailConfiguration.MailPort);
                    }

                    MailMessage message = PrepareMailMessage(subject, body, to, cc, bcc, attachments, emailConfiguration);

                    smtpClient.Send(message);
                }

                return 200;
            }
            catch (Exception ex)
            {
                if (ex.ToString().Contains("5.7.0"))
                {
                    return 500;
                }
                else
                if (ex.ToString().Contains("5.5.1"))
                {
                    return 501;
                }
                else
                    return 502;
            }
        }
        private static MailMessage PrepareMailMessage(string subject, string body, IEnumerable<string> to, IEnumerable<string> cc, IEnumerable<string> bcc, IEnumerable<Attachment> attachments, EmailConfigModel emailConfiguration)
        {
            var message = new MailMessage();
            var fromAddress = new MailAddress(emailConfiguration.MailFrom);

            message.From = fromAddress;
            if (to != null)
            {
                foreach (var item in to.Where(item => !string.IsNullOrWhiteSpace(item)))
                {
                    message.To.Add(item);
                }
            }

            if (cc != null)
            {
                foreach (var item in cc.Where(item => !string.IsNullOrWhiteSpace(item)))
                {
                    message.CC.Add(item);
                }
            }
            if (bcc != null)
            {
                foreach (var item in bcc.Where(item => !string.IsNullOrWhiteSpace(item)))
                {
                    message.Bcc.Add(item);
                }
            }

            message.Subject = subject;
            message.IsBodyHtml = true;
            message.Body = body;

            if (attachments != null)
            {
                foreach (var attachment in attachments)
                {
                    message.Attachments.Add(attachment);
                }
            }

            return message;
        }
    }
}

