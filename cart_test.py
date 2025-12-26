import unittest
from appium import webdriver
from appium.options.android import UiAutomator2Options
from appium.webdriver.common.appiumby import AppiumBy
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
import time

class CartTest(unittest.TestCase):
    def setUp(self):
        options = UiAutomator2Options()
        options.platform_name = 'Android'
        options.device_name = 'emulator-5554'
        options.app_package = 'com.example.flutter_application_1'
        options.app_activity = 'com.example.flutter_application_1.MainActivity'
        options.automation_name = 'UiAutomator2'
        options.set_capability('noReset', True) # Keeps you logged in
        options.set_capability('newCommandTimeout', 300)
        
        self.driver = webdriver.Remote('http://127.0.0.1:4723', options=options)

    def test_cart_flow(self):
        wait = WebDriverWait(self.driver, 25)

        print("\n--- STARTING CART TEST ---")

        # ---------------------------------------------------------
        # STEP 1: Verify Home Screen
        # ---------------------------------------------------------
        print("STEP 1: Checking for Home Screen...")
        try:
            wait.until(EC.presence_of_element_located(
                (AppiumBy.ACCESSIBILITY_ID, "CartIcon")
            ))
            print("   -> Success: Home Screen found.")
        except:
            self.fail("FAILED: Could not find Home Screen. Please run AuthTest first to login!")

        time.sleep(3) # Wait for images to render

        # ---------------------------------------------------------
        # STEP 2: Select a Product
        # ---------------------------------------------------------
        print("STEP 2: Selecting a Product...")
        try:
            # STRATEGY A: Find any image on screen and click the first one
            images = self.driver.find_elements(AppiumBy.CLASS_NAME, "android.widget.ImageView")
            if len(images) > 0:
                images[0].click()
                print("   -> Success: Clicked product image.")
            else:
                raise Exception("No images found")
        except:
            # STRATEGY B: Coordinate Tap (The "Blind" Click)
            print("   -> Image search failed. Trying Coordinate Tap...")
            size = self.driver.get_window_size()
            x = int(size['width'] * 0.25) # 25% across (Left Column)
            y = int(size['height'] * 0.40) # 40% down (Below headers)
            self.driver.tap([(x, y)])
            print(f"   -> Tapped at coordinates: {x}, {y}")

        time.sleep(5) # Wait for Detail Screen to open

        # ---------------------------------------------------------
        # STEP 3: Add to Cart
        # ---------------------------------------------------------
        print("STEP 3: Clicking 'Add to Cart'...")
        try:
            # Search for the button text
            add_btn = wait.until(EC.presence_of_element_located(
                (AppiumBy.ANDROID_UIAUTOMATOR, 'new UiSelector().textContains("Add to Cart")')
            ))
            add_btn.click()
            print("   -> Success: Clicked 'Add to Cart'.")
        except:
            # Fallback: Click the bottom-most button found
            btns = self.driver.find_elements(AppiumBy.CLASS_NAME, "android.widget.Button")
            if len(btns) > 0:
                btns[-1].click() # The last button is usually the main action
            else:
                self.fail("FAILED: No 'Add to Cart' button found.")

        time.sleep(2)

        # ---------------------------------------------------------
        # STEP 4: Navigate to Cart
        # ---------------------------------------------------------
        print("STEP 4: Navigating to Cart Screen...")
        
        # 1. Press Android Back Button to return to Home
        self.driver.press_keycode(4) 
        time.sleep(2)

        # 2. Find and Click Cart Icon
        try:
            cart_icon = wait.until(EC.presence_of_element_located(
                (AppiumBy.ACCESSIBILITY_ID, "CartIcon")
            ))
            cart_icon.click()
            print("   -> Success: Clicked Cart Icon.")
            self.driver.save_screenshot('docs/results/cart_test_screenshot.png')
        except:
            self.fail("FAILED: Could not find Cart Icon after returning home.")

        time.sleep(3)

    def tearDown(self):
        if self.driver:
            self.driver.quit()

if __name__ == '__main__':
    unittest.main()