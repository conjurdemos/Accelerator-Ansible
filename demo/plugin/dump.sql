CREATE TABLE IF NOT EXISTS test (
  message varchar(255) NOT NULL
  ) ENGINE=MyISAM DEFAULT CHARSET=utf8;
  INSERT INTO test(message) VALUES('This is your test data.');
  INSERT INTO test(message) VALUES('Securely provisioned by Ansible.');
  INSERT INTO test(message) VALUES('Made possible by CyberArk Conjur.');
  INSERT INTO test(message) VALUES('and the CyberArk Ansible Galaxy plugin.');
  INSERT INTO test(message) VALUES('https://galaxy.ansible.com/cyberark/conjur')
