backup_rm=$HOME/.rm_backup/

function rm() {
    local opt_force=0
    local opt_interactive=0
    local opt_recursive=0
	
	# Added functionnalities
    local opt_verbose=0
    local opt_empty=0
    local opt_list=0
    local opt_restore=0
    local opt

    OPTERR=0
	
	while getopts ":dfirRvels-:" opt; do
		case $opt in
		d ) ;; #ignored
		f ) opt_force=1 ;;
		i ) opt_interactive=1 ;;
		r | R) opt_recursive=1 ;;
		v ) opt_verbose=1 ;;
		e ) opt_empty=1 ;;
		l ) opt_list=1 ;;
		s ) opt_restore=1 ;;
        - ) case $OPTARG in 
            directory ) ;;
            force ) opt_force=1 ;;
            interactive ) opt_interactive=1 ;;
            recursive ) opt_recursive=1 ;;
            verbose ) opt_verbose=1 ;;
            help ) /bin/rm --help
                echo ""
                echo "rm-secure: (fonctions ajoutées dans un script sourcé dans le ~/.zshrc)"
                echo " -e --empty vider la corbeille"
                echo " -l --list voir le contenu de la corbeille"
                echo " -s --restore récupérer les fichiers"
                return 0 ;;
            version ) /bin/rm --version
                echo "(rm_secure 1)"
                return 0 ;;
            empty ) opt_empty=1 ;;
            list ) opt_list=1 ;;
            restore ) opt_restore=1 ;;
            * ) echo "option illégale --$OPTARG"
                return 1 ;;
            esac ;;
        ? ) echo "option illégale -$OPTARG"
            return 1;;
        esac
    done

    shift $(($OPTIND - 1))

    if [ ! -d "$backup_rm" ] ; then
        mkdir "$backup_rm"
    fi

    if [ $opt_empty -ne 0 ] ; then
        /bin/rm -rf "$backup_rm"
        return 0
    fi

    if [ $opt_list -ne 0 ] ; then
        (   
            cd "$backup_rm"
            if [ `ls -1 | wc -l` -eq 0 ] ; then
                echo "Nothing"
            else
                ls -lRa * 
            fi
        )
    fi

    if [ $opt_restore -ne 0 ] ; then
        while [ -n "$1" ] ; do
            mv "${backup_rm}"/"$1" .
            shift
        done
        return
    fi

    while [ -n "$1" ] ; do
        if [ $opt_force -ne 1 ] && [ $opt_interactive -ne 0 ]
        then
            local response
            echo -n "Détruire $1 ? "
            read response
            if [ "$response" != "y" ] ; then
                shift
                continue
            fi
        fi
        if [ -d "$1" ] && [ $opt_recursive -eq 0 ] ; then
            echo "Les répertoires nécessient l'option récursive. Rien n'est fait pour $1"
            shift
            continue
        fi
        if [ $opt_verbose -ne 0 ] ; then
            echo "Suppression de $1"
        fi
        mv -f "$1" "${backup_rm}"
        if [ $? -ne 0 ] ; then
            shift
            continue;
        fi
        chmod 700 "${backup_rm}/${1##*/}"
        shift
    done
}

trap "/bin/rm -rf $backup_rm" EXIT
