<#setting url_escaping_charset='ISO-8859-1'>
<#include "header.ftl">
<nav>
  <#include "menu.ftl">
</nav>

<header>
  <h1>Claudine Broke It</h1>
</header>
<div id='main'>
    <section>
	
		<article>
			<header>
				<h1><#escape x as x?xml>${content.title}</#escape></h1>
				<small>Posted on ${content.date?string("dd MMMM yyyy")}</small>
			</header>

			<p>${content.body}</p>

			<footer>

	          <ul class="list list--inline">

	            <li><a href="${config.site_host}/${content.uri}?print=1" class="btn btn__article btn--light btn--xs"><i class="fa fa-print" aria-hidden="true"></i></a></li>

	            <#assign twitterUrl = config.site_host + "/" + content.uri>

	            <li><a href="https://twitter.com/intent/tweet?text=${content.title}&url=${twitterUrl?url}&via=iheartpigeons" target="_blank" class="btn btn__profile btn--light btn--xs"><i class="fa fa-twitter" aria-hidden="true"></i></a></li>
	          </ul>

        	</footer>

		</article>
	</section>
	
<#include "sidebar.ftl">

</div>

<#include "footer.ftl">