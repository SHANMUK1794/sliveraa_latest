const { Client } = require('pg');
const connectionString = 'postgresql://postgres:pzuSFBaKrkBqXWUCpNcGkgmblyNdLiXw@interchange.proxy.rlwy.net:49912/railway';

const client = new Client({
  connectionString: connectionString,
});

client.connect()
  .then(() => {
    console.log('Connected successfully');
    return client.query('SELECT NOW()');
  })
  .then(res => {
    console.log('Query result:', res.rows[0]);
    return client.end();
  })
  .catch(err => {
    console.error('Connection error', err.stack);
    process.exit(1);
  });
