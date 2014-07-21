/* (C) 2014 Drew Crawford Apps LLC.  All Rights Reserved.
	Part of the caffeine project, http://caffei.net
	Consult the caffeine license before modifying it or removing it from caffeine.
 */
#ifndef LIBNITROGEN_H
#define LIBNITROGEN_H
#include <stdint.h>
#define LIBNITROGEN_KEYSIZE 32
/** All functions are blocking calls. */

	
/* Returns positive value on success */
int n_client(const char *url, uint8_t publicKey[LIBNITROGEN_KEYSIZE],uint8_t privateKey[LIBNITROGEN_KEYSIZE],uint8_t foreignKey[LIBNITROGEN_KEYSIZE]);
/* returns 0 */
int n_clientdispose(int client);
/* returns bytes sent on success */
int n_clientmsgsend(int client, const char *bytes, int length);
/* returns bytes received.  buffer is memory-managed by libnitrogen and must be disposed */
int n_clientmsgrecv(int client, char **buf);
/* returns 0*/
int n_clientmsgdispose(int client, char *msg);

void n_public_private_keygen(uint8_t *publicKey, uint8_t *privateKey);
#endif