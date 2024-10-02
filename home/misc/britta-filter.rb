#!/usr/bin/env -S ruby -W0

#require 'bundler/setup'
require 'gmail-britta'

if File.exist?(File.expand_path("~/.gmail-britta.personal.rb"))
  CALENDAR_EMAILS = ''
  AMAZON_PACKAGE_TRACKING_EMAIL = ''
  require "~/.gmail-britta.personal.rb"
else
  CALENDAR_EMAILS = ''
  AMAZON_PACKAGE_TRACKING_EMAIL = ''
end

puts(GmailBritta.filterset(:me => MY_EMAILS) do
  to_me = MY_EMAILS.map{|address| "to:#{address}"}
  from_me = MY_EMAILS.map{|address| "from:#{address}"}

    # Archive all mailman mail except confirmation ones
    filter {
      has %w{from:mailman subject:confirm}
      label 'bulk'
      smart_label 'notifications'
    }.otherwise {
      has %w{from:mailman}
      label 'bulk'
      smart_label 'notifications'
      archive
    }

  filter {
      has [{:or => BFF.map{|e| "from:#{e}"}}, {:or => to_me}]
      label BFF_LABEL
      never_spam
    }.otherwise {
      has [{:or => from_me}, {:or => BFF.map{|e| "to:#{e}"}}]
      label BFF_LABEL
      never_spam
    }.archive_unless_directed

    filter {
    has [{:or => SPOUSE.map{|e| "from:#{e}"}}, {:or => to_me}]
      label SPOUSE_LABEL
      mark_important
      never_spam
  }.otherwise {
      has [{:or => from_me}, {:or => SPOUSE.map{|e| "to:#{e}"}}]
      label SPOUSE_LABEL
      mark_important
      never_spam
    }.archive_unless_directed

  filter {
    has [{:or => NOT_MY.map{|e| "to:#{e}"}}]
      label ID_SCAM_LABEL
      archive
      mark_read
    }

    filter {
    has [{:or => AUTHORITIES.map{|e| "from:#{e}"}}, {:or => to_me}]
      label AUTHORITIES_LABEL
      archive
      mark_important
  }.otherwise {
      has [{:or => from_me}, {:or => AUTHORITIES.map{|e| "to:#{e}"}}]
      label AUTHORITIES_LABEL
      archive
      mark_important
    }

    filter {
    has [{:or => from_me}, {:or => PROVIDENCE.map{|e| "to:#{e}"}}]
    label PROVIDENCE_LABEL
    archive
    mark_important
  }.otherwise {
      has [{:or => PROVIDENCE.map{|e| "from:#{e}"}}, {:or => to_me}]
      label PROVIDENCE_LABEL
      archive
      mark_important
    }

    filter {
      has  [{:or => ['from:noreply@humblebundle.com', 'from:support@skillsfaster.com']}]
      label PURCHASES_LABEL
      archive
    }.otherwise {
      has [{:and => ['from:contact@humblebundle.com', 'subject:"Your Humble Bundle order is ready"']}]
      label PURCHASES_LABEL
      archive
    }.otherwise {
      has [{:or => PURCHASES.map{|e| "from:#{e}"}}]
      label PURCHASES
      archive
    }

    # Stuff from the bank:
    filter {
    has [{:or => BANK.map{|e| "from:#{e}"}},{:or => to_me}]
      label 'banking'
      mark_important
  }.otherwise {
      has [{:or => from_me}, {:or => BANK.map{|e| "to:#{e}"}}]
      label 'banking'
      mark_important
    }

  filter {
       has ['from:no-reply@researchgate.net']
       label 'bulk/researchgate'
       smart_label 'social'
    }.otherwise {
      # Mail from web services I don't care about THAT much:
      bacon_senders = %w{sender@mailer.33mail.com store-news@amazon.com thisweek@yelp.com no-reply@vimeo.com
        no-reply@mail.goodreads.com *@carsonified.com *@crossmediaweek.org updates@linkedin.com
        tordotcom@mail.macmillan.com noreply@myopenid.com tor-forge@mail.macmillan.com announce@mailer.evernote.com
        info@getsatisfaction.com Transport_for_London@info.tfl.gov.uk legendsofzork@joltonline.com news@xing.com
        noreply@couchsurfing.com noreply@couchsurfing.org newsletter@getsatisfaction.com store-offers@amazon.com
        gameware@letter.eyepin.com info@busymac.com engage@mail.communications.sun.com *@dotnetsolutions.co.uk
        office@runtasia.at noreply@cellulare.net support@heroku.com team@mixcloud.com automailer@wikidot.com
        no-reply@hi.im linkedin@em.linkedin.com chromium@googlecode.com
        noreply@comixology.com support@plancast.com *@*.boinx.com news@plug.at newsletter@gog.com service@youtube.com
        email@online.cvs.com info@mail.shoprunner.com yammer@yammer.com info@meetup.com support@boostblogtraffic.com
	info@mailer.netflix.com help@otherinbox.com lush.vida@gmail.com udemy@email.udemy.com
	mail@enews.uniqlo-usa.com news@emailnews.meinfernbus.de topangebote@newsletter.voyages-sncf.de
	inquire@mrquikhomeservices.co apress@news.springer.com newsletter@news.fressnapf.de mail@family-newsletter.de
	ticketnews@service.eventim.de noreply@ladyvlondon.com email.campaign@sg.booking.com info@twitter.com
	info@fonografie.de newsletter@hearthis.at mailer@experteer.de newsletter@newsletter.srv2.de
	kundenservice@oyakankerbank.de  inquire@mrquikhomeservices.com noreply@finanzcheck.de service@santander.de
	verizon-info@verizon.com medimops@info.medimops.de *@hoerspielsommer.de mailstrom@410labs.com
	noreply@bandcamp.com noreply@congstarnews.de no-reply@info.twitter.com website@remobjects.com
	newsletter@sounds-exclusive.com no-reply@portal.appdynamics.com info@neues.ebay-kleinanzeigen.de
	ticketalarm@service.eventim.de do-not-reply@amazon.com bestellbestaetigung@amazon.de
	notifications-noreply@linkedin.com noreply@medium.com bestellung@deichmann.com contact@packtpub.com
	karten-online@cinestar.de no-reply@mendeley.com service@glyde.com noreply@jpberlin.de schuenemann-verlag.de
	appintelligence@appdynamics.com mricci@allaboutjazz.com contact@humblebundle.com lieferservice@newsletter.rewe.de
        newsletter@teilauto.net cmail20.com support@smartblogger.com mailer@infusionmail.com noreply@zenva.com
        mail249.suw12.mcsv.net}

      has [{:or => "from:(#{bacon_senders.join("|")})"}]
      archive
      label 'bulk'
      smart_label 'notifications'
    }.otherwise {
      to_me = me.map {|address| "to:#{address}"}
      has [{:or => to_me}]
      label MY_LABEL
    }

    filter {
      has [{:or => ['from:ship-confirm@amazon.com', 'from:auto-confirm@amazon.com']}, {:or => ['subject:"shipped"', 'subject:"tracking number"']}]
      label 'bulk/packages'
      smart_label 'notifications'
      forward_to AMAZON_PACKAGE_TRACKING_EMAIL
    }

    filter {
       has %w{from:support@dnsimple.com}
       archive
       label 'bulk/admin'
       smart_label 'notifications'
    }
 
    filter {
       has %w{from:notifications@github.com}
       archive
       label 'github'
       smart_label 'notifications'
    }
 
    filter {
       has %w{from:stadtbib@leipzig.de}
       label 'bulk'
       smart_label 'notifications'
    }
 
    filter {
       has %w{from:dsl-kundenservice@cc.o2online.de}
       label 'bulk'
       smart_label 'notifications'
    }
 
    filter {
       has ['from:do-not-reply@stackexchange.com', {:or => ['subject:"French Language Weekly Newsletter"', 'subject:"English Language Learners Weekly Newsletter"']}]
       label 'bulk/languages'
       smart_label 'forums'
    }

    filter {
       has CALENDAR_EMAILS
       label 'calendar timer'
       mark_important
       never_spam
    }

  end.generate)
