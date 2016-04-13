​<#include "header.ftl">
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
	</article>
  </section>

  <#include "sidebar.ftl">

</div>

<#include "footer.ftl">