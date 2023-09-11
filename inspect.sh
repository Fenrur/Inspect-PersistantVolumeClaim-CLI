#!/bin/bash

# Vérification si le nombre d'arguments est correct
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <namespace> <claimName>"
    exit 1
fi

NAMESPACE=$1
CLAIM_NAME=$2
POD_NAME="volume-inspect-$((RANDOM % 1000))"

# Création du YAML temporaire après avoir remplacé {1} et {2}
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: $POD_NAME
  namespace: $NAMESPACE
spec:
  containers:
  - name: volume-inspect
    image: busybox
    command:
      - sleep
      - "3600"
    volumeMounts:
    - name: mypvc
      mountPath: /data
  volumes:
  - name: mypvc
    persistentVolumeClaim:
      claimName: $CLAIM_NAME
EOF

# Attendre que le pod soit prêt
while [[ $(kubectl get pods $POD_NAME -n $NAMESPACE -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True" ]]; do 
    echo "Waiting for pod to be ready..."
    sleep 2
done

# Entrer dans le pod en mode shell interactif
kubectl exec -n $NAMESPACE -it $POD_NAME -- /bin/sh -c "cd /data && /bin/sh"

# Kill le pod après avoir quitté le shell interactif
kubectl delete pod $POD_NAME -n $NAMESPACE
