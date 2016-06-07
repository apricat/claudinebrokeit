​<#setting url_escaping_charset='ISO-8859-1'>

<#include "header.ftl">
<nav>
  <#include "menu.ftl">
</nav>

<header>
  <h1>Claudine Broke It</h1>
</header>
<div id='main'>

  <section>

    <header>
      Currently only viewing articles related to <var data-filter-bahaviour="print"></var>... <a href="" class="btn btn__reset btn--dark" data-filter-behavior="reset"><i class="fa fa-filter" aria-hidden="true"></i> Reset filters</a>
    </header>

    <#list posts as post>
    <#if (post.status == "published")>

    <article class="${post.category}" data-tags="<#list post.tags as tag><#assign tagName = tag?replace(' ', '')>${tagName?lower_case} </#list>">
  		<header>
        
  			<ul>
		  		<#list post.tags as tag>
          <#assign tagName = tag?replace(' ', '')>
            <li><a href="" class="highlight--underline filter__tag" data-filter="${tagName?lower_case}">${tag}</a></li>
          </#list>
  			</ul>

  			<h2><#escape x as x?xml>${post.title}</#escape></h2>
  			<small>Posted on ${post.date?string("dd MMMM yyyy")}</small>

  		</header>

        <p>${post.body}</p>

			<footer>

          <ul class="list list--inline">

            <li><a href="${post.uri}?print=1" target="_blank" class="btn btn__article btn--light btn--xs"><i class="fa fa-print" aria-hidden="true"></i></a></li>

            <#assign twitterUrl = config.site_host + "/" + post.uri>

            <li><a href="https://twitter.com/intent/tweet?text=${post.title}&url=${twitterUrl?url}&via=iheartpigeons" target="_blank" class="btn btn__profile btn--light btn--xs"><i class="fa fa-twitter" aria-hidden="true"></i></a></li>
          </ul>

        </footer>
    </article>
	</#if>
	</#list>

  </section>

  <#include "sidebar.ftl">

</div>

<#include "footer.ftl">