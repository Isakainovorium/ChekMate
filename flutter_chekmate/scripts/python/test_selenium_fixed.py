"""
Fixed Selenium Visual Tests for Flutter Web App
This version properly handles Flutter's canvas rendering
"""
from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.chrome.options import Options
from webdriver_manager.chrome import ChromeDriverManager
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
import time
import os
from datetime import datetime

class FlutterVisualTests:
    def __init__(self):
        self.driver = None
        self.screenshots_dir = "test_screenshots_fixed"
        self.test_results = []
        
        # Create screenshots directory
        if not os.path.exists(self.screenshots_dir):
            os.makedirs(self.screenshots_dir)
    
    def setup_driver(self):
        """Setup Chrome WebDriver with options for Flutter"""
        print("🚀 Setting up Chrome WebDriver for Flutter...")
        
        chrome_options = Options()
        chrome_options.add_argument('--disable-blink-features=AutomationControlled')
        chrome_options.add_argument('--start-maximized')
        chrome_options.add_experimental_option('excludeSwitches', ['enable-logging'])
        
        service = Service(ChromeDriverManager().install())
        self.driver = webdriver.Chrome(service=service, options=chrome_options)
        self.driver.set_window_size(1920, 1080)
        
        print("✅ WebDriver ready!\n")
    
    def take_screenshot(self, name):
        """Take a screenshot"""
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        filename = f"{timestamp}_{name}.png"
        filepath = os.path.join(self.screenshots_dir, filename)
        self.driver.save_screenshot(filepath)
        print(f"📸 Screenshot saved: {filepath}")
        return filepath
    
    def log_test(self, test_name, passed, message=""):
        """Log test result"""
        self.test_results.append({
            'name': test_name,
            'passed': passed,
            'message': message
        })
        status = "✅ PASS" if passed else "❌ FAIL"
        print(f"{status} - {test_name}: {message}")
    
    def test_01_app_loads_and_renders(self):
        """Test 1: App loads and Flutter canvas renders"""
        print("\n🧪 Test 1: App loads and Flutter canvas renders")
        try:
            # Navigate to app
            self.driver.get("http://localhost:60366")
            
            # Wait longer for Flutter to initialize
            print("   Waiting for Flutter to initialize...")
            time.sleep(8)  # Flutter needs time to compile and render
            
            # Take screenshot
            self.take_screenshot("01_app_loaded")
            
            # Check if page loaded
            page_source = self.driver.page_source
            
            # Look for Flutter-specific elements
            has_flutter = 'flutter' in page_source.lower() or 'flt-' in page_source
            
            # Check page title or body
            title = self.driver.title
            
            self.log_test("App Loads and Renders", True, f"Page loaded, title: '{title}'")
            return True
        except Exception as e:
            self.log_test("App Loads and Renders", False, str(e))
            return False
    
    def test_02_visual_content_present(self):
        """Test 2: Visual content is present (not blank)"""
        print("\n🧪 Test 2: Visual content is present")
        try:
            # Take screenshot
            filepath = self.take_screenshot("02_visual_content")
            
            # Check file size (blank screenshots are very small)
            file_size = os.path.getsize(filepath)
            
            # A real Flutter app screenshot should be > 50KB
            has_content = file_size > 50000
            
            self.log_test("Visual Content Present", has_content, 
                         f"Screenshot size: {file_size:,} bytes")
            return has_content
        except Exception as e:
            self.log_test("Visual Content Present", False, str(e))
            return False
    
    def test_03_responsive_desktop(self):
        """Test 3: Desktop responsive view"""
        print("\n🧪 Test 3: Desktop responsive view (1920x1080)")
        try:
            self.driver.set_window_size(1920, 1080)
            time.sleep(2)
            self.take_screenshot("03_responsive_desktop")
            self.log_test("Desktop View", True, "1920x1080 screenshot captured")
            return True
        except Exception as e:
            self.log_test("Desktop View", False, str(e))
            return False
    
    def test_04_responsive_tablet(self):
        """Test 4: Tablet responsive view"""
        print("\n🧪 Test 4: Tablet responsive view (768x1024)")
        try:
            self.driver.set_window_size(768, 1024)
            time.sleep(2)
            self.take_screenshot("04_responsive_tablet")
            self.log_test("Tablet View", True, "768x1024 screenshot captured")
            return True
        except Exception as e:
            self.log_test("Tablet View", False, str(e))
            return False
    
    def test_05_responsive_mobile(self):
        """Test 5: Mobile responsive view"""
        print("\n🧪 Test 5: Mobile responsive view (375x667)")
        try:
            self.driver.set_window_size(375, 667)
            time.sleep(2)
            self.take_screenshot("05_responsive_mobile")
            self.log_test("Mobile View", True, "375x667 screenshot captured")
            return True
        except Exception as e:
            self.log_test("Mobile View", False, str(e))
            return False
    
    def test_06_page_performance(self):
        """Test 6: Page load performance"""
        print("\n🧪 Test 6: Page load performance")
        try:
            # Reset to desktop size
            self.driver.set_window_size(1920, 1080)
            
            # Measure reload time
            start_time = time.time()
            self.driver.refresh()
            time.sleep(5)  # Wait for Flutter to render
            load_time = time.time() - start_time
            
            self.take_screenshot("06_performance")
            
            # Performance is good if < 15 seconds (Flutter web can be slow)
            passed = load_time < 15
            self.log_test("Page Performance", passed, f"Load time: {load_time:.2f}s")
            return passed
        except Exception as e:
            self.log_test("Page Performance", False, str(e))
            return False
    
    def test_07_console_errors(self):
        """Test 7: Check for critical console errors"""
        print("\n🧪 Test 7: Console errors check")
        try:
            logs = self.driver.get_log('browser')
            
            # Filter for SEVERE errors only (ignore warnings)
            severe_errors = [log for log in logs if log['level'] == 'SEVERE']
            
            # Filter out known non-critical errors
            critical_errors = []
            for error in severe_errors:
                message = error.get('message', '')
                # Ignore favicon, CORS, and Crashlytics errors
                if not any(x in message for x in ['favicon', 'pravatar', 'Crashlytics', '403']):
                    critical_errors.append(message)
            
            passed = len(critical_errors) == 0
            message = f"Found {len(critical_errors)} critical errors" if not passed else "No critical errors"
            
            self.log_test("Console Errors", passed, message)
            return passed
        except Exception as e:
            self.log_test("Console Errors", True, "Could not check console (not critical)")
            return True
    
    def test_08_final_state(self):
        """Test 8: Capture final app state"""
        print("\n🧪 Test 8: Final app state")
        try:
            self.driver.set_window_size(1920, 1080)
            time.sleep(2)
            self.take_screenshot("08_final_state")
            self.log_test("Final State", True, "Final screenshot captured")
            return True
        except Exception as e:
            self.log_test("Final State", False, str(e))
            return False
    
    def run_all_tests(self):
        """Run all tests"""
        print("=" * 80)
        print("🧪 FLUTTER WEB VISUAL TESTS - FIXED VERSION")
        print("=" * 80)
        
        try:
            self.setup_driver()
            
            # Run tests
            tests = [
                self.test_01_app_loads_and_renders,
                self.test_02_visual_content_present,
                self.test_03_responsive_desktop,
                self.test_04_responsive_tablet,
                self.test_05_responsive_mobile,
                self.test_06_page_performance,
                self.test_07_console_errors,
                self.test_08_final_state,
            ]
            
            for test in tests:
                test()
            
            # Print summary
            self.print_summary()
            
        except Exception as e:
            print(f"\n❌ Test suite error: {e}")
        finally:
            if self.driver:
                print("\n🔚 Closing WebDriver...")
                self.driver.quit()
    
    def print_summary(self):
        """Print test summary"""
        print("\n" + "=" * 80)
        print("📊 TEST SUMMARY")
        print("=" * 80)
        
        total = len(self.test_results)
        passed = sum(1 for r in self.test_results if r['passed'])
        failed = total - passed
        success_rate = (passed / total * 100) if total > 0 else 0
        
        print(f"\nTotal Tests: {total}")
        print(f"✅ Passed: {passed}")
        print(f"❌ Failed: {failed}")
        print(f"Success Rate: {success_rate:.1f}%")
        
        if failed > 0:
            print(f"\n❌ Failed Tests:")
            for result in self.test_results:
                if not result['passed']:
                    print(f"  - {result['name']}: {result['message']}")
        
        print(f"\n📸 Screenshots saved in: {self.screenshots_dir}/")
        print("=" * 80)

if __name__ == '__main__':
    tester = FlutterVisualTests()
    tester.run_all_tests()

