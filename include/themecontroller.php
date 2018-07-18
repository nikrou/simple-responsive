<?php
/*
 * This file is part of Simple Responsive package
 *
 * Copyright(c) Nicolas Roudaire  https://www.phyxo.net/
 * Licensed under the APACHE 2.0 license.
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

namespace BootstrapDarkroom;

class ThemeController
{
    private $config;

    public function __construct()
    {
        $this->config = new Config();
    }

    public function init()
    {
        load_language('theme.lang', PHPWG_THEMES_PATH . 'simple-responsive/');

        add_event_handler('init', array($this, 'assignConfig'));
        add_event_handler('init', array($this, 'setInitValues'));

        if ($this->config->bootstrap_theme === 'darkroom' || $this->config->bootstrap_theme === 'material' || $this->config->bootstrap_theme === 'bootswatch') {
            $this->config->bootstrap_theme = 'bootstrap-darkroom';
            $this->config->save();
            add_event_handler('loc_begin_page_header', array($this, 'showUpgradeWarning'));
        }

        $shortname = $this->config->comments_disqus_shortname;
        if ($this->config->comments_type == 'disqus' && !empty($shortname)) {
            add_event_handler('blockmanager_apply', array($this, 'hideMenus'));
        }

        add_event_handler('loc_begin_page_header', array($this, 'checkIfHomepage'));
        add_event_handler('loc_after_page_header', array($this, 'stripBreadcrumbs'));
        add_event_handler('format_exif_data', array($this, 'exifReplacements'));
        add_event_handler('loc_end_picture', array($this, 'registerPictureTemplates'));
        add_event_handler('loc_begin_index_thumbnails', array($this, 'returnPageStart'));
    }

    public function assignConfig()
    {
        global $template, $conf;

        if (array_key_exists('bootstrap_darkroom_navbar_main_style', $conf) && !empty($conf['bootstrap_darkroom_navbar_main_style'])) {
            $this->config->navbar_main_style = $conf['bootstrap_darkroom_navbar_main_style'];
        }
        if (array_key_exists('bootstrap_darkroom_navbar_main_bg', $conf) && !empty($conf['bootstrap_darkroom_navbar_main_bg'])) {
            $this->config->navbar_main_bg = $conf['bootstrap_darkroom_navbar_main_bg'];
        }
        if (array_key_exists('bootstrap_darkroom_navbar_contextual_style', $conf) && !empty($conf['bootstrap_darkroom_navbar_contextual_style'])) {
            $this->config->navbar_contextual_style = $conf['bootstrap_darkroom_navbar_contextual_style'];
        }
        if (array_key_exists('bootstrap_darkroom_navbar_contextual_bg', $conf) && !empty($conf['bootstrap_darkroom_navbar_contextual_bg'])) {
            $this->config->navbar_contextual_bg = $conf['bootstrap_darkroom_navbar_contextual_bg'];
        }

        $template->assign('theme_config', $this->config);
    }

    public function showUpgradeWarning()
    {
        global $page;
        $page['errors'][] = l10n('Your selected color style has been reset to "bootstrap-darkroom". You can select a different color style in the admin section.');
    }

    public function hideMenus($menus)
    {
        $menu = &$menus[0];

        $mbMenu = $menu->get_block('mbMenu');
        unset($mbMenu->data['comments']);
    }

    public function returnPageStart()
    {
        global $page, $template;

        $template->assign('START_ID', $page['start']);
    }

    public function checkIfHomepage()
    {
        global $template, $page;

        if (isset($page['is_homepage'])) {
            $template->assign('is_homepage', true);
        } else {
            $template->assign('is_homepage', false);
        }
    }

    public function setInitValues()
    {
        global $template, $pwg_loaded_plugins, $conf;

        $template->assign(array(
            'loaded_plugins' => $GLOBALS['pwg_loaded_plugins'],
            'meta_ref_enabled' => $conf['meta_ref']
        ));
        if (array_key_exists('bootstrap_darkroom_core_js_in_header', $conf)) {
            $template->assign('bootstrap_darkroom_core_js_in_header', $conf['bootstrap_darkroom_core_js_in_header']);
        } else {
            $template->assign('bootstrap_darkroom_core_js_in_header', false);
        }

        if (isset($pwg_loaded_plugins['language_switch'])) {
            add_event_handler('loc_end_search', 'language_controler_flags', 95);
            add_event_handler('loc_end_identification', 'language_controler_flags', 95);
            add_event_handler('loc_end_tags', 'language_controler_flags', 95);
            add_event_handler('loc_begin_about', 'language_controler_flags', 95);
            add_event_handler('loc_end_register', 'language_controler_flags', 95);
            add_event_handler('loc_end_password', 'language_controler_flags', 95);
        }

        if (isset($pwg_loaded_plugins['exif_view'])) {
            load_language('lang.exif', PHPWG_PLUGINS_PATH . 'exif_view/');
        }
    }

    public function exifReplacements($exif)
    {
        global $conf;

        if (array_key_exists('bootstrap_darkroom_ps_exif_replacements', $conf)) {
            foreach ($conf['bootstrap_darkroom_ps_exif_replacements'] as $tag => $replacement) {
                if (is_array($exif) && array_key_exists($tag, $exif)) {
                    $exif[$tag] = str_replace($replacement[0], $replacement[1], $exif[$tag]);
                }
            }
        }
        return $exif;
    }

    // register additional template files
    public function registerPictureTemplates()
    {
        global $template;

        $template->set_filenames(array('picture_nav' => 'picture_nav.tpl'));
        $template->assign_var_from_handle('PICTURE_NAV', 'picture_nav');
    }

    public function stripBreadcrumbs()
    {
        global $page, $template;

        $l_sep = $template->get_template_vars('LEVEL_SEPARATOR');
        $title = $template->get_template_vars('TITLE');
        $section_title = $template->get_template_vars('SECTION_TITLE');
        if (empty($title)) {
            $title = $section_title;
        }
        if (!empty($title)) {
            $splt = strpos($title, "[");
            if ($splt) {
                $title_links = substr($title, 0, $splt);
                $title = $title_links;
            }

            $title = str_replace('<a href', '<a class="nav-breadcrumb-item" href', $title);
            $title = str_replace($l_sep, '', $title);
            if ($page['section'] == 'recent_cats' or $page['section'] == 'favorites') {
                $title = preg_replace('/<\/a>([a-zA-Z0-9]+)/', '</a><a class="nav-breadcrumb-item" href="' . make_index_url(array('section' => $page['section'])) . '">${1}', $title) . '</a>';
            }
            if (empty($section_title)) {
                $template->assign('TITLE', $title);
            } else {
                $template->assign('SECTION_TITLE', $title);
            }
        }
    }
}
