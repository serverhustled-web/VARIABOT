#!/usr/bin/env python3
"""
Test suite for termux-url-opener integration
"""

import unittest
import os
import tempfile
import shutil
from pathlib import Path


class TestURLOpenerScript(unittest.TestCase):
    """Test termux-url-opener script exists and is configured correctly"""
    
    def test_url_opener_exists(self):
        """Test that termux-url-opener script exists"""
        script_path = Path("bin/termux-url-opener")
        self.assertTrue(script_path.exists(), "termux-url-opener script should exist")
    
    def test_url_opener_is_executable(self):
        """Test that termux-url-opener has execute permissions"""
        script_path = Path("bin/termux-url-opener")
        self.assertTrue(os.access(script_path, os.X_OK), 
                       "termux-url-opener should be executable")
    
    def test_url_opener_has_shebang(self):
        """Test that termux-url-opener has proper shebang"""
        script_path = Path("bin/termux-url-opener")
        with open(script_path, 'r') as f:
            first_line = f.readline().strip()
        self.assertTrue(first_line.startswith('#!'), 
                       "Script should start with shebang")
        self.assertIn('bash', first_line, 
                     "Script should use bash")
    
    def test_install_script_exists(self):
        """Test that install_url_opener.sh exists"""
        script_path = Path("bin/install_url_opener.sh")
        self.assertTrue(script_path.exists(), "install_url_opener.sh should exist")
    
    def test_install_script_is_executable(self):
        """Test that install_url_opener.sh has execute permissions"""
        script_path = Path("bin/install_url_opener.sh")
        self.assertTrue(os.access(script_path, os.X_OK), 
                       "install_url_opener.sh should be executable")
    
    def test_readme_exists(self):
        """Test that bin/README.md exists"""
        readme_path = Path("bin/README.md")
        self.assertTrue(readme_path.exists(), "bin/README.md should exist")
    
    def test_readme_has_content(self):
        """Test that README has useful content"""
        readme_path = Path("bin/README.md")
        with open(readme_path, 'r') as f:
            content = f.read()
        self.assertIn('termux-url-opener', content.lower(), 
                     "README should mention termux-url-opener")
        self.assertIn('installation', content.lower(), 
                     "README should have installation instructions")
        self.assertIn('configuration', content.lower(), 
                     "README should explain configuration")


class TestTermuxEnvironmentURLSupport(unittest.TestCase):
    """Test TermuxEnvironment URL handling methods"""
    
    def test_termux_environment_import(self):
        """Test that termux_environment module can be imported"""
        try:
            import termux_environment
            self.assertTrue(hasattr(termux_environment, 'TermuxEnvironment'))
        except ImportError as e:
            self.fail(f"Failed to import termux_environment: {e}")
    
    def test_url_methods_exist(self):
        """Test that URL handling methods exist in TermuxEnvironment"""
        from termux_environment import TermuxEnvironment
        
        env = TermuxEnvironment()
        self.assertTrue(hasattr(env, 'setup_url_opener'), 
                       "Should have setup_url_opener method")
        self.assertTrue(hasattr(env, 'get_url_queue'), 
                       "Should have get_url_queue method")
        self.assertTrue(hasattr(env, 'get_pending_urls'), 
                       "Should have get_pending_urls method")
        self.assertTrue(hasattr(env, 'clear_pending_urls'), 
                       "Should have clear_pending_urls method")
    
    def test_setup_url_opener_returns_dict(self):
        """Test that setup_url_opener returns a dictionary"""
        from termux_environment import TermuxEnvironment
        
        env = TermuxEnvironment()
        result = env.setup_url_opener()
        self.assertIsInstance(result, dict, 
                            "setup_url_opener should return a dict")
        self.assertIn('status', result, 
                     "Result should have status key")
    
    def test_get_url_queue_returns_list(self):
        """Test that get_url_queue returns a list"""
        from termux_environment import TermuxEnvironment
        
        env = TermuxEnvironment()
        # This will return empty list if not in Termux or file doesn't exist
        result = env.get_url_queue()
        self.assertIsInstance(result, list, 
                            "get_url_queue should return a list")
    
    def test_environment_report_includes_url_setup(self):
        """Test that environment report includes URL opener setup"""
        from termux_environment import TermuxEnvironment
        
        env = TermuxEnvironment()
        report = env.get_environment_report()
        self.assertIn('url_opener_setup', report, 
                     "Environment report should include url_opener_setup")


class TestURLOpenerConfiguration(unittest.TestCase):
    """Test URL opener configuration and defaults"""
    
    def test_script_has_configuration_section(self):
        """Test that script includes configuration setup"""
        script_path = Path("bin/termux-url-opener")
        with open(script_path, 'r') as f:
            content = f.read()
        
        self.assertIn('CONFIG_FILE', content, 
                     "Script should define CONFIG_FILE")
        self.assertIn('load_config', content, 
                     "Script should have load_config function")
        self.assertIn('AUTO_PROCESS', content, 
                     "Script should handle AUTO_PROCESS config")
        self.assertIn('DEFAULT_ACTION', content, 
                     "Script should handle DEFAULT_ACTION config")
    
    def test_script_has_logging(self):
        """Test that script includes logging functionality"""
        script_path = Path("bin/termux-url-opener")
        with open(script_path, 'r') as f:
            content = f.read()
        
        self.assertIn('LOG_FILE', content, 
                     "Script should define LOG_FILE")
        self.assertIn('log_message', content, 
                     "Script should have log_message function")
    
    def test_script_has_url_validation(self):
        """Test that script validates URLs"""
        script_path = Path("bin/termux-url-opener")
        with open(script_path, 'r') as f:
            content = f.read()
        
        self.assertIn('validate_url', content, 
                     "Script should have validate_url function")
    
    def test_script_has_variabot_integration(self):
        """Test that script integrates with VARIABOT"""
        script_path = Path("bin/termux-url-opener")
        with open(script_path, 'r') as f:
            content = f.read()
        
        self.assertIn('VARIABOT', content, 
                     "Script should reference VARIABOT")
        self.assertIn('process_url_with_variabot', content, 
                     "Script should have VARIABOT processing function")


def run_tests():
    """Run all tests and display results"""
    # Create test suite
    loader = unittest.TestLoader()
    suite = unittest.TestSuite()
    
    # Add test cases
    suite.addTests(loader.loadTestsFromTestCase(TestURLOpenerScript))
    suite.addTests(loader.loadTestsFromTestCase(TestTermuxEnvironmentURLSupport))
    suite.addTests(loader.loadTestsFromTestCase(TestURLOpenerConfiguration))
    
    # Run tests
    runner = unittest.TextTestRunner(verbosity=2)
    result = runner.run(suite)
    
    # Return exit code
    return 0 if result.wasSuccessful() else 1


if __name__ == '__main__':
    exit(run_tests())

# References:
# - Internal: /reference_vault/PRODUCTION_GRADE_STANDARDS.md#testing-standards
# - Internal: /reference_vault/ORGANIZATION_STANDARDS.md#file-organization
# - External: Python unittest — https://docs.python.org/3/library/unittest.html
