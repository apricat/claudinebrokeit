​<#include "header.ftl">
<nav>
  <#include "menu.ftl">
</nav>

<header>
  <h1>Claudine Broke It</h1>
</header>
<div id='main'>

  <section>

    <#list posts as post>
    <#if (post.status == "published")>
    <article>
  		<header>
        
  			<ul>
		  		<#list post.tags as tag>
            <li><a href="" class="highlight--underline">${tag}</a></li>
          </#list>
  			</ul>

  			<a href="${post.uri}"><h2><#escape x as x?xml>${post.title}</#escape></h2></a>
  			<small>Posted on ${post.date?string("dd MMMM yyyy")}</small>

  		</header>

        <p>${post.body}</p>

			<footer>
      
          <a class="highlight--underline" href="${post.uri}">Read this article</a>

          <ul class="list list--inline">
            <li><a href="https://twitter.com/intent/tweet?text=${post.title?url}" class="btn btn__profile btn--light btn--xs"><i class="fa fa-twitter" aria-hidden="true"></i></a></li>
          </ul>

        </footer>
    </article>
	</#if>
	</#list>

  </section>

  <#include "sidebar.ftl">

</div>

<#include "footer.ftl">