<footer>&copy; Claudine Lamothe</footer>
  </div>
    
    
    <script>
      var codeElement = document.querySelectorAll('pre code');
      for (var j = 0; j < codeElement.length; j++) {
        padSubsequentLines(codeElement[j]);
      }

      function padSubsequentLines(element) {
        var
          words = element.innerHTML.split(/\n/g),
          html = '',
          i;
        for (i = 0; i < words.length; i++) {
          html += '<span>' + words[i] + ' </span>';
        }
        element.innerHTML = html;
      }
      </script>

    <script src="<#if (content.rootpath)??>${content.rootpath}<#else></#if>js/jquery-1.11.1.min.js"></script>
    <script src="<#if (content.rootpath)??>${content.rootpath}<#else></#if>js/prettify.js"></script>
  </body>
</html>