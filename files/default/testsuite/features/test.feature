Feature: Test Feature

As an build job in the continuous delivery pipeline
I want to know that a new deployment didn't break the system
So that I can rollback to the previously working release and keep the system running

Scenario: Check Hana Port
  When I look at port "30015" on "localhost"
  Then it should be open
