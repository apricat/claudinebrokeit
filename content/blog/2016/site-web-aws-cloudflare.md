title=Amazon Web Services & CloudFlare
date=2016-06-01
type=post
category=code
tags=cloud, AWS, CloudFlare
status=published
~~~~~~

![Bukkits](images/cloudflare-et-bucket.png "Bukkits dans le cloud")

Aujourd'hui, petit billet en français pour partager une méthode fort pratique et abordable pour mettre en ligne des sites statiques avec Amazon Web Services (AWS) et CloudFlare.

> Petit lancé de fleurs vers le brilliant [Frédéric Bournival](https://fredericbournival.com/), qui m'a guidé étape par étape au travers de ce processus.

### Nom de domaine

Prenons pour acquis que vous êtes déjà le fier propriétaire d'un nom de domaine chez un _registrar_. Si ce n'est pas le cas, `ahbincoudon.cc` est [disponible](https://ca.godaddy.com/domains/searchresults.aspx?checkAvail=1&domainToCheck=ahbincoudon.cc).

### AWS (_ah-double-vé-ess_)

Ensuite, pour entamer le processus, il faut un compte [AWS](http://aws.amazon.com/).

AWS offre ses services [S3](https://aws.amazon.com/s3/) d'espace infonuagique gratuitement* pendant 12 mois sous le nom *Free Tier*. _Deal_.

*Quelques limites s'imposent :

	* 5GB de _Standard Storage_
	* 20,000 requêtes _Get_
	* 2,000 requêtes _Put_

S3, c'est leur service de stockage. On crée des *buckets* pour stocker et récupérer des *objets* dans le nuage.

### Buckets

	1. https://console.aws.amazon.com/console/home?region=us-east-1
	2. Sélectionner *S3*
	3. *Simple Storage Service*

Il nous faut donc créer deux *buckets* *S3* -- un pour notre domaine et l'autre pour la redirection `www` -- dans la region la plus proche 

> N. Virginia, pour moi, n'est qu'à une distance négligeable de 1,149km. Par contre, une erreur de parcours a eu pour conséquence que ce site est situé en Caroline du Nord.

	claudinebroke.it
	www.claudinebroke.it

Ensuite, il faut sélectionner le premier _bucket_ (`claudinebroke.it`) pour éditer ses _properties_. Sélectionnez _Static website hosting_ et _Enable website hosting_. Ensuite, il faut lui attribuer des permissions. Dans _Bucket Policy_ : 

	{
	  "Version": "2012-10-17",
	  "Statement": [
	    {
	      "Sid": "PublicReadForGetBucketObjects",
	      "Effect": "Allow",
	      "Principal": "*",
	      "Action": "s3:GetObject",
	      "Resource": "arn:aws:s3:::claudinebroke.it/*"
	    }
	  ]
	}

Pour le _bucket_ `www`, sélectionnez _Redirect all requests to another host name_. _Merci bonsoir._

Vous pouvez dès lors accéder à votre site! E.g.

	http://claudinebroke.it.s3-website-us-west-1.amazonaws.com/


### SYNC avec AWSCLI

Prochaine étape : *syncer* son contenu avec AWS. Depuis Ubuntu, on peut installer le _package management system_ `python-pip`, qui nous permet d'installer `awscli` : un outil de gestion en ligne de commande pour AWS [(documentation)](http://docs.aws.amazon.com/cli/latest/userguide/cli-chap-welcome.html).

	sudo apt-get update
	sudo apt-get -y install python-pip
	pip install awscli
	

> Dans mon cas, j'ai intégré les commandes dans mon script de *automated provisioning* de *Vagrant*.

Ensuite, il vous faut créer un utilisateur et lui attribuer une _key-pair_.

Depuis la console Web d'AWS, cliquez sur IAM - [Identity & Access Management](https://console.aws.amazon.com/iam/home?region=us-east-1#home)

Créez un utilisateur. E.g. `s3bucketsync`, et laissez le système générer la valeur _key-pair_. Sauvegardez le _access key_ et sélectionnez l'utilisateur nouvellement créé. 

Dans _permission_ :

	attach policy
	
Filtrez pour *s3* et sélectionner :
	
	AmazonS3FullAccess

Maintenant, de retour dans notre environnement Linux, on peut configurer l'outil `AWSCLI`.

	aws configure
	AWS Access Key ID [None]: YOURSECRETID
	AWS Secret Access Key [None]: YOURSECRETKEY
	Default region name [None]: us-east-1
	Default output format [None]: json


Ensuite, vous n'avez qu'à naviguer jusqu'au dossier que vous désirez envoyer dans les nuages et rouler cette commande :

	aws s3 sync . s3://claudinebroke.it --region us-west-1

> Mes *buckets* ayant voyager un peu, le paramètre facultatif `--region` est utilisé pour outrepasser l'option `Default region name` désignée auparavant avec l'outil `AWSCLI`.

### CloudFlare

Maintenant, `http://claudinebroke.it.s3-website-us-west-1.amazonaws.com/`, comme addresse Web, c'est pas simple simple  à partager à vive voix dans un pub bruyant quand tu veux que tes amis ailles voir ton dernier billet de blog. Bref, il nous faut un alias, colloquialement appelé du `CNAME Flattening`, pour faire le pont entre notre addresse AWS et notre nom de domaine.

[CloudFlare](https://www.cloudflare.com/), c'est aussi une fantastique couche de sécurité et de *cache* pour votre site Web. Pis c'est gratuit, oui oui.

Créez-vous un compte CloudFlare, puis sélectionnez `DNS`. Vous aurez de besoin, au minimum, de deux entrées :

	CNAME (i) *Flattening* | claudinebroke.it | is an alias of claudinebroke.it.s3-website-us-west-1.amazonaws.com | Automatic | *Petit nuage transpercé d'une flèche*
	CNAME | www | is an alias of claudinebroke.it | Automatic | *Petit nuage transpercé d'une flèche*


CloudFlare vous attribue ensuite des *nameservers*. E.g.

		sam.ns.cloudflare.com
		eve.ns.cloudflare.com

La dernière étape consiste à retourner chez le *registrar* -- là où vous vous êtes procuré vos noms de domaines -- pour lier les *nameservers* aux noms de domaines.

### Conclusion

Et c'est tout! `claudinebroke.it` affiche maintenant le contenu de `claudinebroke.it.s3-website-us-west-1.amazonaws.com`.

Ça peut prendre quelques temps pour que les `DNS Records` se rafraîchissent, par contre, donc profitez de cette petite pause et marquez l'occasion avec une bonne bière!