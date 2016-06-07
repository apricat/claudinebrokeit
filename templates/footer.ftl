<footer>&copy; Claudine Lamothe</footer>
  </div>
    
    
<script>

var resetBtn = document.querySelector("[data-filter-behavior='reset']");

removeResetBtn();
bindFiltering();

resetBtn.onclick = function()
{
  removeResetBtn();
  resetFiltering();

  return false;
}

function bindFiltering()
{
  var tags = document.querySelectorAll("[data-filter]");
  if (!tags) 
    return false;

  for (i = 0; i < tags.length; ++i) {

    tags[i].onclick = function() {
      showResetBtn();
      resetFiltering();

      document.querySelector("[data-filter-bahaviour='print']").innerHTML = this.getAttribute("data-filter");

      var articles = document.querySelectorAll("article:not([data-tags~=" + this.getAttribute("data-filter") + "])");
      for (i = 0; i < articles.length; ++i) {
        articles[i].className += articles[i].className ? ' hidden' : 'hidden';
      }

      return false;
    };
    
  }
}

function removeResetBtn()
{
  resetBtn.parentNode.classList.add("hidden");
}

function showResetBtn()
{
  resetBtn.parentNode.classList.remove("hidden");
}

function resetFiltering() 
{
    var hidden = document.querySelectorAll("article.hidden");
    for (i = 0; i < hidden.length; ++i) {
        hidden[i].classList.remove("hidden");
    }
}

var codeBlocks = document.querySelectorAll('pre code');

for (var j = 0; j < codeBlocks.length; j++) {
  codeBlocks[j].innerHTML = wrapLines(highlightSyntax(codeBlocks[j].innerHTML));
}

function highlightSyntax(html) 
{
  var matches = {
    "access-mod" : /(public|private|protected)/g,
    "type" : /(String|long|int|char|bool)/g,
    "keyword" : /(use|class\s|namespace|function|implements|const)/g,
    "operator" : /(\|\||&&|\+|\-\s|((!|=|==|!==|!=)(?=\s)))+/g,
    "comment" : /(\/\*[\S\s]+?\*\/)/,
    "method" : /(\w+)(\()/g,
    "condition" : /(if|else|return)/g,
    "annotation" : /(@Override)/g
  };
  
  for (var key in matches) { 
    if (matches.hasOwnProperty(key)) {
      var tag = "<em class='code__highlight code__highlight--"+ key +"'>$1</em>";
      
      if (key == "method") 
        tag += "("; // override for group $2 removing opening brace on match replace
      
      html = html.replace(matches[key], tag);
    }
  }
  
  return html;
}

function wrapLines(html) 
{
  var lines = html.split(/\n/g),
      html  = '';
  for (var i = 0; i < lines.length - 1; i++) {
    html += '<span>' + lines[i] + ' </span>';
  }
  return html;
}

function getQueryParams(qs) {
    qs = qs.split('+').join(' ');

    var params = {},
        tokens,
        re = /[?&]?([^=]+)=([^&]*)/g;

    while (tokens = re.exec(qs)) {
        params[decodeURIComponent(tokens[1])] = decodeURIComponent(tokens[2]);
    }

    return params;
}

var query = getQueryParams(document.location.search);
if (query.print) {
  window.print();
}
      </script>

      <script>
      
      (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
      (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
      m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
      })(window,document,'script','https://www.google-analytics.com/analytics.js','ga');

      ga('create', 'UA-76901929-1', 'auto');
      ga('send', 'pageview');

    </script>

    <script src="<#if (content.rootpath)??>${content.rootpath}<#else></#if>js/jquery-1.11.1.min.js"></script>
    <script src="<#if (content.rootpath)??>${content.rootpath}<#else></#if>js/prettify.js"></script>
  </body>
</html>