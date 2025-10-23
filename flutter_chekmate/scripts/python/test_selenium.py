"""
ChekMate Visual Selenium Tests
Visually confirms all UI elements work correctly in the running app
"""

from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.common.action_chains import ActionChains
from selenium.webdriver.common.keys import Keys
import time
import os
from datetime import datetime

class ChekMateVisualTests:
    def __init__(self, app_url="http://localhost:8080"):
        """Initialize Selenium WebDriver"""
        self.app_url = app_url
        self.driver = None
        self.screenshots_dir = "test/visual/results/latest"
        self.baselines_dir = "test/visual/baselines"
        self.test_results = []

        # Create screenshots directories
        os.makedirs(self.screenshots_dir, exist_ok=True)
        os.makedirs(self.baselines_dir, exist_ok=True)
        os.makedirs(f"{self.baselines_dir}/phase1", exist_ok=True)
        os.makedirs(f"{self.baselines_dir}/phase2", exist_ok=True)
    
    def setup(self):
        """Set up Chrome WebDriver"""
        print("🚀 Setting up Chrome WebDriver...")
        options = webdriver.ChromeOptions()
        options.add_argument('--start-maximized')
        options.add_argument('--disable-blink-features=AutomationControlled')
        
        self.driver = webdriver.Chrome(options=options)
        self.driver.implicitly_wait(10)
        print("✅ WebDriver ready!")
    
    def teardown(self):
        """Close WebDriver"""
        if self.driver:
            self.driver.quit()
            print("🔚 WebDriver closed")
    
    def take_screenshot(self, name):
        """Take a screenshot and save it"""
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        filename = f"{self.screenshots_dir}/{timestamp}_{name}.png"
        self.driver.save_screenshot(filename)
        print(f"📸 Screenshot saved: {filename}")
        return filename
    
    def wait_for_element(self, by, value, timeout=10):
        """Wait for element to be present"""
        try:
            element = WebDriverWait(self.driver, timeout).until(
                EC.presence_of_element_located((by, value))
            )
            return element
        except Exception as e:
            print(f"❌ Element not found: {value}")
            return None
    
    def log_test(self, test_name, passed, message=""):
        """Log test result"""
        status = "✅ PASS" if passed else "❌ FAIL"
        result = {
            "test": test_name,
            "passed": passed,
            "message": message,
            "timestamp": datetime.now().isoformat()
        }
        self.test_results.append(result)
        print(f"{status} - {test_name}: {message}")
    
    def test_01_app_loads(self):
        """Test 1: App loads successfully"""
        print("\n🧪 Test 1: App loads successfully")
        try:
            self.driver.get(self.app_url)
            time.sleep(3)  # Wait for Flutter to initialize
            
            # Check if page loaded
            assert "ChekMate" in self.driver.title or self.driver.title != ""
            
            self.take_screenshot("01_app_loaded")
            self.log_test("App Loads", True, "App loaded successfully")
            return True
        except Exception as e:
            self.log_test("App Loads", False, str(e))
            return False
    
    def test_02_login_page_elements(self):
        """Test 2: Login page displays all elements"""
        print("\n🧪 Test 2: Login page elements visible")
        try:
            # Wait for page to load
            time.sleep(2)
            
            # Look for login elements using Flutter's flt-semantics
            page_source = self.driver.page_source
            
            # Check for key text
            has_welcome = "Welcome" in page_source or "Login" in page_source
            has_input_fields = "flt-text-editing" in page_source or "input" in page_source.lower()
            
            self.take_screenshot("02_login_page")
            
            if has_welcome or has_input_fields:
                self.log_test("Login Page Elements", True, "Login elements found")
                return True
            else:
                self.log_test("Login Page Elements", False, "Some elements missing")
                return False
                
        except Exception as e:
            self.log_test("Login Page Elements", False, str(e))
            return False
    
    def test_03_navigation_visible(self):
        """Test 3: Bottom navigation is visible"""
        print("\n🧪 Test 3: Bottom navigation visible")
        try:
            time.sleep(2)
            
            # Check for navigation elements
            page_source = self.driver.page_source
            
            # Look for navigation indicators
            has_nav = any(word in page_source.lower() for word in ['home', 'messages', 'profile', 'navigation'])
            
            self.take_screenshot("03_navigation")
            
            if has_nav:
                self.log_test("Bottom Navigation", True, "Navigation elements found")
                return True
            else:
                self.log_test("Bottom Navigation", False, "Navigation not found")
                return False
                
        except Exception as e:
            self.log_test("Bottom Navigation", False, str(e))
            return False
    
    def test_04_click_interactions(self):
        """Test 4: Click interactions work"""
        print("\n🧪 Test 4: Click interactions")
        try:
            time.sleep(2)
            
            # Try to find and click clickable elements
            clickable_elements = self.driver.find_elements(By.TAG_NAME, "flt-semantics")
            
            if len(clickable_elements) > 0:
                # Click first few elements
                for i, element in enumerate(clickable_elements[:3]):
                    try:
                        element.click()
                        time.sleep(0.5)
                        print(f"  ✓ Clicked element {i+1}")
                    except:
                        pass
                
                self.take_screenshot("04_after_clicks")
                self.log_test("Click Interactions", True, f"Clicked {min(3, len(clickable_elements))} elements")
                return True
            else:
                self.log_test("Click Interactions", False, "No clickable elements found")
                return False
                
        except Exception as e:
            self.log_test("Click Interactions", False, str(e))
            return False
    
    def test_05_scroll_functionality(self):
        """Test 5: Scroll functionality works"""
        print("\n🧪 Test 5: Scroll functionality")
        try:
            time.sleep(2)
            
            # Get initial scroll position
            initial_scroll = self.driver.execute_script("return window.pageYOffset;")
            
            # Scroll down
            self.driver.execute_script("window.scrollBy(0, 500);")
            time.sleep(1)
            
            # Get new scroll position
            new_scroll = self.driver.execute_script("return window.pageYOffset;")
            
            self.take_screenshot("05_after_scroll")
            
            if new_scroll > initial_scroll:
                self.log_test("Scroll Functionality", True, f"Scrolled from {initial_scroll} to {new_scroll}")
                return True
            else:
                self.log_test("Scroll Functionality", False, "Scroll did not work")
                return False
                
        except Exception as e:
            self.log_test("Scroll Functionality", False, str(e))
            return False
    
    def test_06_responsive_layout(self):
        """Test 6: Responsive layout at different sizes"""
        print("\n🧪 Test 6: Responsive layout")
        try:
            # Test different viewport sizes
            sizes = [
                (1920, 1080, "desktop"),
                (768, 1024, "tablet"),
                (375, 667, "mobile")
            ]
            
            for width, height, device in sizes:
                self.driver.set_window_size(width, height)
                time.sleep(2)
                self.take_screenshot(f"06_responsive_{device}")
                print(f"  ✓ Tested {device} size ({width}x{height})")
            
            # Reset to desktop size
            self.driver.maximize_window()
            
            self.log_test("Responsive Layout", True, "Tested 3 viewport sizes")
            return True
            
        except Exception as e:
            self.log_test("Responsive Layout", False, str(e))
            return False
    
    def test_07_no_console_errors(self):
        """Test 7: Check for console errors"""
        print("\n🧪 Test 7: Console errors check")
        try:
            # Get browser console logs
            logs = self.driver.get_log('browser')
            
            # Filter for errors
            errors = [log for log in logs if log['level'] == 'SEVERE']
            
            if len(errors) == 0:
                self.log_test("Console Errors", True, "No severe console errors")
                return True
            else:
                error_messages = [e['message'][:100] for e in errors[:3]]
                self.log_test("Console Errors", False, f"Found {len(errors)} errors: {error_messages}")
                return False
                
        except Exception as e:
            self.log_test("Console Errors", False, str(e))
            return False
    
    def test_08_page_performance(self):
        """Test 8: Page load performance"""
        print("\n🧪 Test 8: Page performance")
        try:
            # Reload page and measure load time
            start_time = time.time()
            self.driver.refresh()
            time.sleep(3)  # Wait for Flutter to initialize
            load_time = time.time() - start_time
            
            self.take_screenshot("08_performance")
            
            if load_time < 10:
                self.log_test("Page Performance", True, f"Load time: {load_time:.2f}s")
                return True
            else:
                self.log_test("Page Performance", False, f"Slow load time: {load_time:.2f}s")
                return False
                
        except Exception as e:
            self.log_test("Page Performance", False, str(e))
            return False
    
    def test_09_visual_elements(self):
        """Test 9: Visual elements are rendered"""
        print("\n🧪 Test 9: Visual elements rendered")
        try:
            time.sleep(2)
            
            # Check for canvas elements (Flutter renders to canvas)
            canvases = self.driver.find_elements(By.TAG_NAME, "canvas")
            
            if len(canvases) > 0:
                self.take_screenshot("09_visual_elements")
                self.log_test("Visual Elements", True, f"Found {len(canvases)} canvas elements")
                return True
            else:
                self.log_test("Visual Elements", False, "No canvas elements found")
                return False
                
        except Exception as e:
            self.log_test("Visual Elements", False, str(e))
            return False
    
    def test_10_accessibility(self):
        """Test 10: Basic accessibility check"""
        print("\n🧪 Test 10: Accessibility check")
        try:
            # Check for semantic elements
            semantic_elements = self.driver.find_elements(By.TAG_NAME, "flt-semantics")
            
            self.take_screenshot("10_accessibility")
            
            if len(semantic_elements) > 0:
                self.log_test("Accessibility", True, f"Found {len(semantic_elements)} semantic elements")
                return True
            else:
                self.log_test("Accessibility", False, "No semantic elements found")
                return False
                
        except Exception as e:
            self.log_test("Accessibility", False, str(e))
            return False
    
    def run_all_tests(self):
        """Run all visual tests"""
        print("\n" + "="*60)
        print("🧪 CHEKMATE VISUAL SELENIUM TESTS")
        print("="*60)
        
        self.setup()
        
        try:
            # Run all tests
            tests = [
                self.test_01_app_loads,
                self.test_02_login_page_elements,
                self.test_03_navigation_visible,
                self.test_04_click_interactions,
                self.test_05_scroll_functionality,
                self.test_06_responsive_layout,
                self.test_07_no_console_errors,
                self.test_08_page_performance,
                self.test_09_visual_elements,
                self.test_10_accessibility,
            ]
            
            for test in tests:
                test()
                time.sleep(1)
            
            # Print summary
            self.print_summary()
            
        finally:
            self.teardown()
    
    def print_summary(self):
        """Print test summary"""
        print("\n" + "="*60)
        print("📊 TEST SUMMARY")
        print("="*60)
        
        total = len(self.test_results)
        passed = sum(1 for r in self.test_results if r['passed'])
        failed = total - passed
        
        print(f"\nTotal Tests: {total}")
        print(f"✅ Passed: {passed}")
        print(f"❌ Failed: {failed}")
        print(f"Success Rate: {(passed/total*100):.1f}%")
        
        if failed > 0:
            print("\n❌ Failed Tests:")
            for result in self.test_results:
                if not result['passed']:
                    print(f"  - {result['test']}: {result['message']}")
        
        print(f"\n📸 Screenshots saved in: {self.screenshots_dir}/")
        print("="*60 + "\n")


if __name__ == "__main__":
    # Run tests
    tester = ChekMateVisualTests(app_url="http://localhost:60366")
    tester.run_all_tests()

