from playwright.sync_api import sync_playwright
from datetime import datetime
import time
import re
import pyperclip
import imaplib
import email
import random

# Email credentials for the first Gmail account
EMAIL_ACCOUNT = "skytrade.ui.test@gmail.com"
APP_PWD = "pmsw mkpn hhlv dygc"
EMAIL_FOLDER = "inbox"

num = random.randint(1, 10000000)

# Email credentials for the second Gmail account
SECOND_EMAIL_ACCOUNT = f"skytrade.ui.test+{num}@gmail.com"
APP_PWD_SECOND = "pmsw mkpn hhlv dygc"

def extract_verification_code(subject):
    """Extract a 6-digit verification code from the email subject."""
    match = re.search(r'\b\d{6}\b', subject)
    if match:
        return match.group(0)
    else:
        return None

def read_verification_email(email_account, app_pwd):
    """Read the latest verification email and extract the OTP code."""
    M = imaplib.IMAP4_SSL('imap.gmail.com')
    M.login(email_account, app_pwd)
    M.select(EMAIL_FOLDER)

    rv, data = M.search(None, "ALL")
    if rv != 'OK':
        print("No messages found!")
        return None

    latest_email_id = data[0].split()[-1]
    rv, data = M.fetch(latest_email_id, '(RFC822)')
    if rv != 'OK':
        print("ERROR getting message", latest_email_id)
        return None, None

    msg = email.message_from_bytes(data[0][1])
    email_subject = msg['Subject']
    email_body = ""

    if msg.is_multipart():
        for part in msg.walk():
            if part.get_content_type() == "text/plain":
                try:
                    email_body = part.get_payload(decode=True).decode('utf-8')
                except UnicodeDecodeError:
                    email_body = part.get_payload(decode=True).decode('latin-1')
                break
    else:
        try:
            email_body = msg.get_payload(decode=True).decode('utf-8')
        except UnicodeDecodeError:
            email_body = msg.get_payload(decode=True).decode('latin-1')

    M.logout()

    print(f"Email Subject: {email_subject}")
    return email_subject, email_body

# Function to extract the referral link and code from the email body
def extract_referral_link_and_code(email_body):
    # Adjust the regex to match the specific pattern in your email content
    link_match = re.search(r'https://sky\.trade/r/[\w]{6}', email_body)
    if link_match:
        referral_link = link_match.group(0)
        referral_code = link_match.group(0).split("/")[-1]  # Last part of the URL
        return referral_link, referral_code
    return None, None


def select_current_date(page):
    current_date = str(datetime.now().day)
    buttons = page.locator("button.MuiButtonBase-root.MuiPickersDay-root")

    for i in range(buttons.count()):
        if buttons.nth(i).inner_text() == current_date:
            buttons.nth(i).click()
            break

def click_available_button(page):
    points_button = page.locator("a[href='/points']")
    referral_button = page.locator("a[href='/referral']")

    if points_button.count() > 0:
        points_button.click()
    elif referral_button.count() > 0:
        referral_button.click()
    else:
        print("Neither button is available.")

with sync_playwright() as playwright:
    browser = playwright.chromium.launch(headless=False)
    context = browser.new_context()

    try:
        page = context.new_page()
        page.goto("https://dev.sky.trade/")
        page.wait_for_load_state("networkidle", timeout=0)
        print("Opened SkyTrade")

        page.locator("button.rounded.text-white").click()
        page.wait_for_load_state("networkidle", timeout=0)
        print("Accepted cookies")

        page.locator("p[class='md:block hidden']").click()
        print("Opened Login page")

        page.locator("input[id='email']").fill(EMAIL_ACCOUNT)
        page.locator("button.bg-dark-blue").click()
        page.wait_for_load_state("networkidle", timeout=0)
        print("Filled email and clicked login")

        time.sleep(15)
        email_subject, email_body = read_verification_email(EMAIL_ACCOUNT, APP_PWD)

        if email_subject:
            verification_code = extract_verification_code(email_subject)
            if verification_code:
                print(f"Verification Code: {verification_code}")
                page.bring_to_front()
                otp_inputs = page.locator(".otp-input-container .otp-input")
                for i, digit in enumerate(verification_code):
                    otp_inputs.nth(i).fill(digit)
                print("Filled verification code")
                page.wait_for_load_state("networkidle", timeout=0)

        page.wait_for_load_state("networkidle", timeout=0)

        # Check for first login page and wait for it to escape
        first_login = page.locator("input[placeholder='email@mail.com']")
        #first_login.wait_for(timeout=30000)
        time.sleep(5)
        
        if first_login.is_visible():
            print("First login page found, waiting for the next step")
            page.wait_for_load_state("networkidle", timeout=0)
        else:
            print("First login page not found, proceeding to the next step")

        page.wait_for_load_state("networkidle", timeout=0)
        #time.sleep(10)

        # Airspace Claim Testing
        dash_board = page.locator("div.relative.z-20")
        airspace_section = dash_board.locator("a[href='/airspaces']").click()
        page.wait_for_load_state('networkidle', timeout=0)
        time.sleep(60)
        # reactour_close = page.locator("button.reactour__close-button")
        # reactour_close.wait_for(timeout=0)
        # reactour_close.click()
        airspace_address = page.locator("input[id='searchAirspaces']")
        airspace_address.fill("20 Henley Street, Port Elizabeth")
        page.locator("div[class='w-[10%] h-6 mr-2']").nth(0).click()
        page.locator("div.Claim-airspacebtn-step").click()
        page.locator("select[id='timeZone']").select_option("Africa/Harare")
        page.locator("input[id='hasStorageHub']").click()
        page.keyboard.press('PageDown')
        page.wait_for_timeout(1000)

        # Daily Availability
        daily_availability = [
            ('0', '6', '21'),  # Sunday
            ('1', '7', '20'),  # Monday
            ('2', '7', '20'),  # Tuesday
            ('3', '7', '20'),  # Wednesday
            ('6', '6', '21')   # Saturday
        ]

        for day, start, end in daily_availability:
            page.locator(f"select[id='{day}/start']").select_option(start)
            page.locator(f"select[id='{day}/end']").select_option(end)
        
        # Thursday and Friday (Unavailability)
        page.locator("label.cursor-pointer.items-center").nth(4).click()  # Thursday
        page.locator("label.cursor-pointer.items-center").nth(5).click()  # Friday

        time.sleep(2)

        page.keyboard.press('PageDown')
        page.wait_for_timeout(1000)

        page.locator("input[id='zone-dont-know']").click()
        page.locator("div.Claim-airspacebtn2-step").click()
        print("Airspace Claiming Completed")
        page.wait_for_load_state("networkidle", timeout=0)
        #time.sleep(5)

        #Fund testing
        page.locator("a[href='/funds']").click()
        page.locator("div.transform.transition-transform.duration-300").click() # Payment option dropdown
        page.keyboard.press('PageDown')
        page.wait_for_timeout(1000)
        page.locator("li.flex").nth(0).click() # Select Native Payment Option
        page.locator("div.relative").nth(4).click() # Copy Deposit Wallet ID
        time.sleep(1)  # Give a moment for the clipboard to update
        deposit_id = pyperclip.paste()
        print(f"Wallet Id: {deposit_id}")
        page.keyboard.press('PageUp')
        page.wait_for_timeout(1000)
        page.locator("div.text-center.cursor-pointer.w-full").nth(1).click() # Withdrawal button
        page.keyboard.press('PageDown')
        page.wait_for_timeout(1000)
        page.locator("input[id='amount']").fill("300") # Amount
        page.locator("input[id='walletId']").fill(deposit_id) # Paste Deposit Wallet ID
        page.locator("button.text-white.flex.items-center").click() # Final withdrawal button
        print("Fund Testing Completed")
        page.wait_for_load_state("networkidle", timeout=0)

        # Airspace Rent Testing
        dash_board.locator("a[href='/rent']").click()
        #page.locator("a[href='/rent']").click()
        page.wait_for_load_state("networkidle", timeout=0)
        time.sleep(40)
        page.locator("input[id='searchAirspaces']").fill("1025 Robertson Street, Fort Collins, Colorado")
        #address = page.locator("div[data-value='2955 Baseline Rd, Boulder, Colorado 80303, United States']")
        address = page.locator("div[class='w-full p-5 text-left text-[#222222]  ']").nth(0)
        address.wait_for(timeout=0)
        address.click()
        time.sleep(15)
        rent_to_click = page.locator("div[data-value='1025 Robertson St Fort Collins CO']").nth(0)
        rent_to_click.wait_for(timeout=0)
        rent_to_click.locator("span.rounded-lg.text-center").click()
        page.locator("svg[data-testid='CalendarIcon']").click()
        select_current_date(page)
        page.locator("button.MuiButtonBase-root.MuiButton-root").click()
        #page.locator("button[aria-colindex='4']").nth(4).click()
        # page.locator("li[aria-label='10 hours']").click()
        # page.locator("li[aria-label='PM']").click()
        page.locator("button.flex").click()
        page.locator("div.text-center").click()
        print("Airspace Renting Completed")
        page.wait_for_load_state("networkidle", timeout=0)
        #time.sleep(5)

        # Send referral to the second email
        click_available_button(page)
        page.keyboard.press('PageDown')
        page.locator("div.cursor-pointer.transition.ease-linear.delay-75").nth(1).click()
        page.locator("input[id='friendEmail']").fill(SECOND_EMAIL_ACCOUNT)  # Fill second email
        page.wait_for_timeout(1000)
        page.locator("div.justify-center.cursor-pointer.rounded-lg").nth(3).click()  # Send referral link and code
        page.locator("p[class='font-normal text-[#5D7285] text-[14.64px] tracking-[1%]']").nth(7).click()  # Logout
        print("Referral link sent")
        page.wait_for_load_state("networkidle", timeout=0)

       # Reading the latest email from the second Gmail account
        email_subject, email_body = read_verification_email(SECOND_EMAIL_ACCOUNT, APP_PWD_SECOND)

        # Extracting the referral link and code
        if email_body:
            referral_link, referral_code = extract_referral_link_and_code(email_body)
            if referral_link and referral_code:
                print(f"Referral Link: {referral_link}")
                print(f"Referral Code: {referral_code}")
            else:
                print("Referral link or code not found in the email body.")
        else:
            print("No email found for referral extraction.")

    except Exception as e:
        print(f"Error: {e}")
    finally:
        context.close()
        browser.close()