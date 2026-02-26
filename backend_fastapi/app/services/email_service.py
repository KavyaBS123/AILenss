import smtplib
import logging
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from app.core.config import settings

logger = logging.getLogger(__name__)


class EmailService:
    """Service to send emails via Zoho SMTP"""

    @staticmethod
    def send_otp_email(recipient_email: str, otp_code: str) -> bool:
      print("EmailService.send_otp_email called with:", recipient_email, otp_code)
      """
      Send OTP to user's email address
        
      Args:
        recipient_email: User's email address
        otp_code: One-time password to send
        
      Returns:
        bool: True if email was sent successfully, False otherwise
      """
      try:
        # Email configuration
        sender_email = settings.SMTP_EMAIL
        sender_password = (settings.SMTP_PASSWORD or "").replace(" ", "").strip()
        smtp_server = settings.SMTP_SERVER
        smtp_port = int(settings.SMTP_PORT)
        print(f"[DEBUG] Loaded SMTP_EMAIL: '{sender_email}'")
        print(f"[DEBUG] Loaded SMTP_PASSWORD: '{sender_password}' (length: {len(sender_password)})")

        if not sender_email or not sender_password:
            logger.error("❌ SMTP credentials missing. Check SMTP_EMAIL/SMTP_PASSWORD.")
            return False

        # Create message
        message = MIMEMultipart("alternative")
        message["Subject"] = "Your AILens OTP Code"
        message["From"] = sender_email
        message["To"] = recipient_email

        # Create HTML email body
        html = f"""
        <html>
          <body style='font-family: Arial, sans-serif; background-color: #f4f4f4; padding: 20px;'>
            <div style='max-width: 500px; margin: 0 auto; background-color: white; padding: 30px; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.1);'>
              <h2 style='color: #333; text-align: center; margin-bottom: 30px;'>AILens OTP Verification</h2>
              <p style='color: #666; font-size: 16px; margin-bottom: 20px;'>Hi there,</p>
              <p style='color: #666; font-size: 16px; margin-bottom: 30px;'>Your One-Time Password (OTP) for AILens is:</p>
              <div style='background-color: #f0f0f0; padding: 20px; border-radius: 8px; text-align: center; margin-bottom: 30px;'>
                <p style='font-size: 36px; font-weight: bold; color: #007bff; letter-spacing: 5px; margin: 0;'>{otp_code}</p>
              </div>
              <p style='color: #666; font-size: 14px; margin-bottom: 10px;'>This OTP is valid for 10 minutes.</p>
              <p style='color: #666; font-size: 14px; margin-bottom: 20px;'>If you didn't request this OTP, please ignore this email.</p>
              <hr style='border: none; border-top: 1px solid #ddd; margin: 30px 0;'>
              <p style='color: #999; font-size: 12px; text-align: center;'>AILens - Biometric Identity Protection</p>
            </div>
          </body>
        </html>
        """
        part = MIMEText(html, "html")
        message.attach(part)

        try:
            if smtp_port == 587:
                with smtplib.SMTP(smtp_server, smtp_port, timeout=10) as server:
                    server.ehlo()
                    server.starttls()
                    server.ehlo()
                    server.login(sender_email, sender_password)
                    server.sendmail(sender_email, recipient_email, message.as_string())
            else:
                with smtplib.SMTP_SSL(smtp_server, smtp_port, timeout=10) as server:
                    server.login(sender_email, sender_password)
                    server.sendmail(sender_email, recipient_email, message.as_string())
            print("✅ OTP email sent successfully!")
            return True
        except smtplib.SMTPAuthenticationError as e:
            logger.error(f"❌ SMTP Authentication failed: {e}")
            return False
        except Exception as e:
          logger.error(f"❌ Failed to send OTP email: {e}")
          return False

        # Send email via Gmail SMTP
        logger.info(f"📧 Sending OTP email to: {recipient_email}")
        with smtplib.SMTP_SSL(smtp_server, smtp_port, timeout=10) as server:
            server.login(sender_email, sender_password)
            server.sendmail(sender_email, recipient_email, message.as_string())

        logger.info(f"✓ OTP email sent successfully to: {recipient_email}")
        return True
      except smtplib.SMTPAuthenticationError:
        logger.error("❌ SMTP Authentication failed. Check email and app password.")
        return False
      except smtplib.SMTPException as e:
        logger.error(f"❌ SMTP error occurred: {str(e)}")
        return False
      except Exception as e:
        logger.error(f"❌ Error sending email: {str(e)}")
        return False
