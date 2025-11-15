# Cloud Build Configuration

This `cloudbuild.yaml` file automates the Docker image build and deployment process.

## Steps:

1. **Build** - Builds the Docker image with both `latest` and commit SHA tags
2. **Push** - Pushes the image to Artifact Registry
3. **Update Instance** - Updates the Compute Engine instance with the new image
4. **Verify** - Confirms the deployment and displays the instance's public IP

## Setup:

1. Connect your GitHub repository to Cloud Build:
   ```bash
   gcloud builds connect --repository=gcloud-terraform --github-owner=fadiloderinu
   ```

2. Create a Cloud Build trigger:
   ```bash
   gcloud builds triggers create github \
     --name="Flask Backend Deploy" \
     --repo-name="gcloud-terraform" \
     --repo-owner="fadiloderinu" \
     --branch-pattern="^main$" \
     --build-config="cloudbuild.yaml"
   ```

3. Grant Cloud Build the necessary permissions:
   ```bash
   # Get your Cloud Build service account
   gcloud iam service-accounts list --filter="displayName:Cloud Build"
   
   # Grant Compute Admin role
   gcloud projects add-iam-policy-binding groovy-student-475217-a3 \
     --member=serviceAccount:YOUR_BUILD_SERVICE_ACCOUNT@cloudbuild.gserviceaccount.com \
     --role=roles/compute.admin
   
   # Grant Artifact Registry Writer role
   gcloud projects add-iam-policy-binding groovy-student-475217-a3 \
     --member=serviceAccount:YOUR_BUILD_SERVICE_ACCOUNT@cloudbuild.gserviceaccount.com \
     --role=roles/artifactregistry.writer
   ```

## Trigger:

The workflow automatically triggers on every push to the `main` branch.

## Customization:

Edit the `substitutions` section in `cloudbuild.yaml` to match your setup:
- `_REGION` - Artifact Registry region
- `_REGISTRY_NAME` - Your registry name
- `_IMAGE_NAME` - Your image name
- `_INSTANCE_NAME` - Your compute instance name
- `_ZONE` - Your GCP zone
- `_APP_PORT` - Your application port
