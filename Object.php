<?php
    declare(strict_types=1);
    class composer_modules {
        private const modules = [
            "twig" => __DIR__."/twig/vendor/autoload.php",
        ];

        private static function load_module(string $module):void {
            if(isset(self::modules[$module]) !== TRUE) {
                die("<b>Fatal error:</b> Module $module is not supported");
            }
            if(is_file(self::modules[$module]) !== TRUE) {
                die("<b>Fatal error:</b> Module $module not found");
            }
            require_once(self::modules[$module]);
        }

        public static function load(array|string $modules):void {
            if(is_string($modules) === TRUE) {
                self::load_module($modules);
            } else {
                foreach($modules as $module) {
                    self::load_module($module);
                }
            }
        }
    }
