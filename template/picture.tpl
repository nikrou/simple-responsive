<!-- Start of picture.tpl -->
{if get_device() != 'desktop'}
{combine_script id='jquery.mobile-events' path='themes/bootstrap_darkroom/js/jquery.mobile-events.min.js' require='jquery' load='footer'}
{/if}

{if !empty($PLUGIN_PICTURE_BEFORE)}{$PLUGIN_PICTURE_BEFORE}{/if}

{$PICTURE_NAV}

<div class="container{if $theme_config->fluid_width}-fluid{/if}">
{include file='infos_errors.tpl'}

  <div class="row justify-content-center">
    {include file='picture_nav_buttons.tpl'|@get_extent:'picture_nav_buttons'}
  </div>
{if get_device() != 'desktop' }
{footer_script require="jquery"}{strip}
$('#theImage img').bind('swipeleft swiperight', function (event) {
   if (event.type == 'swipeleft') {
       $('#navigationButtons a#navNextPicture i').click();
   } else if (event.type == 'swiperight') {
       $('#navigationButtons a#navPrevPicture i').click(); 
   } else { 
       return;
   }
});
{/strip}{/footer_script}
{/if}

  <div id="theImage" class="row d-block justify-content-center mb-3">
    {$ELEMENT_CONTENT}
  </div>

{if $theme_config->picture_info == 'sidebar'}
    {$PICTURE_INFO_SIDEBAR}
{/if}

  <div id="theImageComment" class="row justify-content-center mb-3">
{if isset($COMMENT_IMG)}
    <div class="text-center col-lg-10 -col-md-12 mx-auto">
      <section id="important-info">
        <h4 class="imageComment">{$COMMENT_IMG}</h4>
      </section>
    </div>
{/if}
  </div>

{include file="http_scheme.tpl"}
{if $theme_config->social_enabled}
  <div id="theImageShareButtons" class="row justify-content-center">
    <section id="share">
{if $theme_config->social_twitter}
        <a href="http://twitter.com/share?text={$current.TITLE}&amp;url={$http_scheme}://{$smarty.server.HTTP_HOST}{$smarty.server.REQUEST_URI}"
           onclick="window.open(this.href, 'twitter-share', 'width=550,height=235');return false;" title="Share on Twitter">
            <i class="fa fa-twitter"></i>
        </a>
{/if}
{if $theme_config->social_facebook}
        <a href="https://www.facebook.com/sharer/sharer.php?u={$http_scheme}://{$smarty.server.HTTP_HOST}{$smarty.server.REQUEST_URI}"
           onclick="window.open(this.href, 'facebook-share','width=580,height=296');return false;" title="Share on Facebook">
            <i class="fa fa-facebook"></i>
        </a>
{/if}
{if $theme_config->social_google_plus}
        <a href="https://plus.google.com/share?url={$http_scheme}://{$smarty.server.HTTP_HOST}{$smarty.server.REQUEST_URI}"
           onclick="window.open(this.href, 'google-plus-share', 'width=490,height=530');return false;" title="Share on Google+">
            <i class="fa fa-google-plus"></i>
        </a>
{/if}
{if $theme_config->social_pinterest}
        <a href="http://www.pinterest.com/pin/create/button/?url={$http_scheme}://{$smarty.server.HTTP_HOST}{$smarty.server.REQUEST_URI}&media={$http_scheme}://{$smarty.server.HTTP_HOST}{$smarty.server.REQUEST_URI}/../{$current.selected_derivative->get_url()}"
           onclick="window.open(this.href, 'pinterest-share', 'width=490,height=530');return false;" title="Pin it!">
            <i class="fa fa-pinterest"></i>
        </a>
{/if}
    </section>
  </div>
{/if}

{if !empty($thumbnails) && ($theme_config->slick_enabled || $theme_config->photoswipe)}
  {if $theme_config->slick_enabled && sizeOf($thumbnails) > 1}
    {include file="_slick_js.tpl"}
  {/if}
  {if $theme_config->photoswipe && !$theme_config->slick_infinite}
    {include file="_photoswipe_js.tpl" selector="#thumbnailCarousel"}
  {/if}
  {if $theme_config->photoswipe && $theme_config->slick_infinite}
    {include file="_photoswipe_js.tpl" selector="#photoSwipeData"}
  {/if}
  <div id="theImageCarousel" class="row mx-0">
    <div class="col-lg-10 col-md-12 mx-auto">
      <div id="thumbnailCarousel" class="slick-carousel">
  {assign var=idx value=0}
  {foreach from=$thumbnails item=thumbnail}
  {assign var=derivative value=$pwg->derivative($derivative_params_square, $thumbnail.src_image)}
  {if !$theme_config->slick_infinite}
    {assign var=derivative_medium value=$pwg->derivative($derivative_params_medium, $thumbnail.src_image)}
    {assign var=derivative_large value=$pwg->derivative($derivative_params_large, $thumbnail.src_image)}
    {assign var=derivative_xxlarge value=$pwg->derivative($derivative_params_xxlarge, $thumbnail.src_image)}
  {/if}
  {if !$derivative->is_cached()}
    {combine_script id='jquery.ajaxmanager' path='themes/default/js/plugins/jquery.ajaxmanager.js' load='footer'}
    {combine_script id='thumbnails.loader' path='themes/default/js/thumbnails.loader.js' require='jquery.ajaxmanager' load='footer'}
  {/if}
  {if !$theme_config->slick_infinite}
        <div class="text-center{if $thumbnail.id eq $current.id && !$theme_config->slick_infinite} thumbnail-active{/if}">
          <a{if $thumbnail.id eq $current.id} id="thumbnail-active"{/if} href="{$thumbnail.URL}" data-index="{$idx}" data-name="{$thumbnail.NAME}" data-description="{$thumbnail.DESCRIPTION}" {if !$theme_config->slick_infinite}data-src-xlarge="{$derivative_xxlarge->get_url()}" data-size-xlarge="{$derivative_xxlarge->get_size_hr()}" data-src-large="{$derivative_large->get_url()}" data-size-large="{$derivative_large->get_size_hr()}" data-src-medium="{$derivative_medium->get_url()}" data-size-medium="{$derivative_medium->get_size_hr()}"{if preg_match("/(mp4|m4v)$/", $thumbnail.PATH)} data-src-original="{$U_HOME}{$thumbnail.PATH}" data-size-original="{$thumbnail.SIZE}" data-video="true"{else}{if $theme_config->photoswipe_metadata} data-exif-make="{$thumbnail.EXIF.make}" data-exif-model="{$thumbnail.EXIF.model}" data-exif-lens="{$thumbnail.EXIF.lens}" data-exif-iso="{$thumbnail.EXIF.iso}" data-exif-apperture="{$thumbnail.EXIF.apperture}" data-exif-shutter-speed="{$thumbnail.EXIF.shutter_speed}" data-exif-focal-length="{$thumbnail.EXIF.focal_length}" data-date-created="{$thumbnail.DATE_CREATED}"{/if}{/if}{/if}>
  {else}
        <div class="text-center{if $thumbnail.id eq $current.id} thumbnail-active{/if}"><a href="{$thumbnail.URL}">
  {/if}
          <img {if $derivative->is_cached()}data-lazy="{$derivative->get_url()}"{else}data-lazy="{$ROOT_URL}{$themeconf.icon_dir}/img_small.png" data-src="{$derivative->get_url()}"{/if} alt="{$thumbnail.TN_ALT}" title="{$thumbnail.TN_TITLE}" class="img-fluid"></a>
        </div>
  {assign var=idx value=$idx+1}
  {/foreach}
      </div>
    </div>
  </div>

  {if $theme_config->slick_infinite}
  <div id="photoSwipeData">
    {assign var=idx value=0}
    {foreach from=$thumbnails item=thumbnail}
    {assign var=derivative_medium value=$pwg->derivative($derivative_params_medium, $thumbnail.src_image)}
    {assign var=derivative_large value=$pwg->derivative($derivative_params_large, $thumbnail.src_image)}
    {assign var=derivative_xxlarge value=$pwg->derivative($derivative_params_xxlarge, $thumbnail.src_image)}
    <a{if $thumbnail.id eq $current.id} id="thumbnail-active"{/if} href="{$thumbnail.URL}" data-index="{$idx}" data-name="{$thumbnail.NAME}" data-description="{$thumbnail.DESCRIPTION}" data-src-xlarge="{$derivative_xxlarge->get_url()}" data-size-xlarge="{$derivative_xxlarge->get_size_hr()}" data-src-large="{$derivative_large->get_url()}" data-size-large="{$derivative_large->get_size_hr()}" data-src-medium="{$derivative_medium->get_url()}" data-size-medium="{$derivative_medium->get_size_hr()}"{if preg_match("/(mp4|m4v)$/", $thumbnail.PATH)} data-src-original="{$U_HOME}{$thumbnail.PATH}" data-size-original="{$thumbnail.SIZE}" data-video="true"{else}{if $theme_config->photoswipe_metadata} data-exif-make="{$thumbnail.EXIF.make}" data-exif-model="{$thumbnail.EXIF.model}" data-exif-lens="{$thumbnail.EXIF.lens}" data-exif-iso="{$thumbnail.EXIF.iso}" data-exif-apperture="{$thumbnail.EXIF.apperture}" data-exif-shutter-speed="{$thumbnail.EXIF.shutter_speed}" data-exif-focal-length="{$thumbnail.EXIF.focal_length}" data-date-created="{$thumbnail.DATE_CREATED}"{/if}{/if}></a>
{assign var=idx value=$idx+1}
    {/foreach}
  </div>
  {/if}
{/if}


  <div id="theImageInfos" class="row">
{if $theme_config->picture_info == 'cards'}
    {$PICTURE_INFO_CARDS}
{elseif $theme_config->picture_info == 'tabs'}
    {$PICTURE_INFO_TABS}
{elseif $theme_config->picture_info == 'sidebar' || $theme_config->picture_info == 'disabled'}
    <div class="col-lg-8 col-md-10 col-12 mx-auto">
      {$PICTURE_INFO_COMMENTS}
    </div>
{/if}
  </div>

{if !empty($PLUGIN_PICTURE_AFTER)}{$PLUGIN_PICTURE_AFTER}{/if}

</div>
