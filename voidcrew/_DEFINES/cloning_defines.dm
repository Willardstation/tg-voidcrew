//cloning defines. These are flags.
#define CLONING_SUCCESS (1<<0)
#define CLONING_DELETE_RECORD (1<<1)
#define CLONING_SUCCESS_EXPERIMENTAL (1<<2)

//This defines for cloning
#define CLONER_FRESH_CLONE "fresh"
#define CLONER_MATURE_CLONE "mature"
#define CLONING_POD_TRAIT "cloning_pod_trait"

#define ERROR_NO_SYNTHFLESH 101
#define ERROR_PANEL_OPENED 102
#define ERROR_MESS_OR_ATTEMPTING 103
#define ERROR_MISSING_EXPERIMENTAL_POD 104
#define ERROR_NOT_MIND 201
#define ERROR_PRESAVED_CLONE 202
#define ERROR_OUTDATED_CLONE 203
#define ERROR_ALREADY_ALIVE 204
#define ERROR_COMMITED_SUICIDE 205
#define ERROR_SOUL_DEPARTED 206
#define ERROR_SUICIDED_BODY 207
#define ERROR_UNCLONABLE 901

#define rustg_hash_string(algorithm, text) call(RUST_G, "hash_string")(algorithm, text)
#define RUSTG_HASH_MD5 "md5"
#define ROLE_EXPERIMENTAL_CLONE "Experimental Clone"
#define COMSIG_MACHINE_CLOSE "machine_close"
#define COMSIG_MACHINE_OPEN "machine_open"
